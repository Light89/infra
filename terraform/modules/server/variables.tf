variable "server_name" {
  type = string
}

variable "server_type" {
  type = string
}

variable "location" {
  type = string
}

variable "network_id" {
  type = string
}

variable "firewall_id" {
  type = string
}

variable "admin_user" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "server_role" {
  type        = string
  description = "The role of the server (e.g. docker-host, base, utility)"
  default     = "base"
}
