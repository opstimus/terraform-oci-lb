output "load_balancer_id" {
  description = "The OCID of the load balancer."
  value       = oci_load_balancer_load_balancer.main.id
}

output "load_balancer_ip_addresses" {
  description = "The IP address details of the load balancer."
  value       = oci_load_balancer_load_balancer.main.ip_address_details
}

output "public_ip_address" {
  description = "The public IP address assigned to the load balancer by OCI. Null when the load balancer is private."
  value       = var.is_private == true ? null : one([for ip in oci_load_balancer_load_balancer.main.ip_address_details : ip.ip_address if ip.is_public == true])
}

output "nsg_id" {
  description = "The OCID of the NSG attached to the load balancer. Add this to backend compute instances to allow LB egress traffic."
  value       = oci_core_network_security_group.main.id
}

output "http_backend_set_name" {
  description = "The name of the HTTP backend set."
  value       = oci_load_balancer_backend_set.http.name
}

output "https_backend_set_name" {
  description = "The name of the HTTPS backend set."
  value       = oci_load_balancer_backend_set.https.name
}
