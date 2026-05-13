output "load_balancer_id" {
  description = "The OCID of the load balancer."
  value       = oci_load_balancer_load_balancer.main.id
}

output "load_balancer_ip_addresses" {
  description = "The IP address details of the load balancer."
  value       = oci_load_balancer_load_balancer.main.ip_address_details
}

output "public_ip_id" {
  description = "The OCID of the reserved public IP. Null when the load balancer is private."
  value       = one(oci_core_public_ip.main[*].id)
}

output "public_ip_address" {
  description = "The reserved public IP address. Null when the load balancer is private."
  value       = one(oci_core_public_ip.main[*].ip_address)
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
