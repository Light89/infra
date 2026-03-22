variable "hcloud_token" {
  type        = string
  description = "Hetzner Cloud API Token"
  sensitive   = true
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for the admin user"
}

variable "allowed_ssh_ips" {
  type        = list(string)
  description = "List of IPs allowed to connect via SSH"
  default     = ["0.0.0.0/0"]
}
