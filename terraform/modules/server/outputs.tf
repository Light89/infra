output "server_id" {
  value = hcloud_server.main.id
}

output "public_ip" {
  value = hcloud_server.main.ipv4_address
}
