resource "oci_core_network_security_group" "main" {
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.project}-${var.environment}-lb"
  freeform_tags  = var.tags
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_http" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_https" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_egress" {
  network_security_group_id = oci_core_network_security_group.main.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
}

resource "oci_load_balancer_load_balancer" "main" {
  compartment_id               = var.compartment_id
  display_name                 = "${var.project}-${var.environment}-${var.is_private == true ? "private" : "public"}-lb"
  shape                        = "flexible"
  subnet_ids                   = var.subnet_ids
  freeform_tags                = var.tags
  ip_mode                      = "IPV4"
  is_delete_protection_enabled = true
  is_private                   = var.is_private
  network_security_group_ids   = [oci_core_network_security_group.main.id]
  is_request_id_enabled        = var.is_request_id_enabled
  request_id_header            = var.is_request_id_enabled == true ? "X-Request-ID" : null
  security_attributes          = var.security_attributes
  shape_details {
    maximum_bandwidth_in_mbps = var.maximum_bandwidth_in_mbps
    minimum_bandwidth_in_mbps = var.minimum_bandwidth_in_mbps
  }
}

resource "oci_load_balancer_load_balancer_routing_policy" "main" {
  load_balancer_id           = oci_load_balancer_load_balancer.main.id
  name                       = "main_routing"
  condition_language_version = "V1"

  # Required to satisfy OCI's "at least one rule" constraint at create time.
  # Microservices will overwrite this list via the upsert script.
  rules {
    name      = "default_placeholder"
    condition = "http.request.url.path sw '/__placeholder__'"
    actions {
      name             = "FORWARD_TO_BACKENDSET"
      backend_set_name = oci_load_balancer_backend_set.https.name
    }
  }

  lifecycle {
    ignore_changes = [rules]
  }
}


resource "oci_load_balancer_backend_set" "http" {
  health_checker {
    protocol    = "HTTP"
    url_path    = var.health_check_url_path
    port        = var.health_check_port
    return_code = 200
  }
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  name             = "${var.project}-${var.environment}-http-backend-set"
  policy           = var.backend_set_policy
}

resource "oci_load_balancer_backend_set" "https" {
  health_checker {
    protocol    = "HTTP"
    url_path    = var.health_check_url_path
    port        = var.health_check_port
    return_code = 200
  }
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  name             = "${var.project}-${var.environment}-https-backend-set"
  policy           = var.backend_set_policy
}

resource "oci_load_balancer_listener" "http" {
  default_backend_set_name = oci_load_balancer_backend_set.http.name
  load_balancer_id         = oci_load_balancer_load_balancer.main.id
  name                     = "${var.project}-${var.environment}-http-listener"
  port                     = 80
  protocol                 = "HTTP"
  rule_set_names           = [oci_load_balancer_rule_set.http_redirect.name]
}

resource "oci_load_balancer_listener" "https" {
  default_backend_set_name = oci_load_balancer_backend_set.https.name
  load_balancer_id         = oci_load_balancer_load_balancer.main.id
  name                     = "${var.project}-${var.environment}-https-listener"
  port                     = 443
  protocol                 = "HTTP"
  routing_policy_name      = oci_load_balancer_load_balancer_routing_policy.main.name

  connection_configuration {
    idle_timeout_in_seconds = var.listener_connection_configuration_idle_timeout_in_seconds
  }
  ssl_configuration {
    certificate_ids         = var.listener_ssl_configuration_certificate_ids
    has_session_resumption  = true
    cipher_suite_name       = "oci-default-ssl-cipher-suite-v1"
    protocols               = ["TLSv1.2"]
    verify_peer_certificate = false
  }
}

resource "oci_load_balancer_rule_set" "http_redirect" {
  items {
    action = "REDIRECT"

    conditions {
      attribute_name  = "PATH"
      attribute_value = "/"
      operator        = "FORCE_LONGEST_PREFIX_MATCH"
    }

    redirect_uri {
      host     = "{host}"
      path     = "/{path}"
      port     = 443
      protocol = "HTTPS"
      query    = "?{query}"
    }
    response_code = 301
  }
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  name             = replace("${var.project}_${var.environment}_https_redirect", "-", "_")
}
