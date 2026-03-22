variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for the admin user"
}

variable "allowed_ssh_ips" {
  type        = list(string)
  description = "List of IPs allowed to connect via SSH"
  default     = ["0.0.0.0/0"]
}
variable "servers" {
  type = map(object({
    server_type = string
    location    = string
    role        = string
  }))
  default = {
    "dev-docker-01" = {
      server_type = "cx23"
      location    = "nbg1"
      role        = "docker-host"
    }
  }
}
