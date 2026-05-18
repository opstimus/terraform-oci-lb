variable "project" {
  description = "The name of the project."
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)."
  type        = string
}

variable "vcn_id" {
  description = "The OCID of the VCN where the load balancer will be created."
  type        = string
}

variable "compartment_id" {
  description = "The OCID of the compartment where the resources will be created."
  type        = string
}

variable "subnet_ids" {
  description = "A list of subnet OCIDs to be used for the load balancer."
  type        = list(string)
}

variable "is_private" {
  description = "Whether the load balancer is private or public."
  type        = bool
  default     = false
}

variable "is_request_id_enabled" {
  description = "Whether to enable request ID header for the load balancer."
  type        = bool
  default     = false
}

variable "security_attributes" {
  description = "The security attributes for the load balancer."
  type        = map(string)
  default     = null
}

variable "maximum_bandwidth_in_mbps" {
  description = "The maximum bandwidth in Mbps for the load balancer shape."
  type        = number
  default     = 1000
}

variable "minimum_bandwidth_in_mbps" {
  description = "The minimum bandwidth in Mbps for the load balancer shape."
  type        = number
  default     = 10
}

variable "backend_set_policy" {
  description = "The load balancing policy for the backend set (e.g., ROUND_ROBIN, LEAST_CONNECTIONS, IP_HASH)."
  type        = string
  default     = "ROUND_ROBIN"
  validation {
    condition     = contains(["ROUND_ROBIN", "LEAST_CONNECTIONS", "IP_HASH"], var.backend_set_policy)
    error_message = "backend_set_policy must be one of ROUND_ROBIN, LEAST_CONNECTIONS, or IP_HASH."
  }
}

variable "health_check_url_path" {
  description = "The URL path for the health check (e.g., /health)."
  type        = string
  default     = "/health"
}

variable "health_check_port" {
  description = "The port on the backend to use for health checks."
  type        = number
  default     = 80
}

variable "listener_connection_configuration_idle_timeout_in_seconds" {
  description = "The idle timeout in seconds for the listener connection configuration."
  type        = number
  default     = 60
}

variable "listener_ssl_configuration_certificate_ids" {
  description = "A list of certificate OCIDs to be associated with the backend set for SSL termination."
  type        = list(string)
}

variable "tags" {
  description = "Free-form tags to apply to all resources in this module."
  type        = map(string)
  default     = null
}
