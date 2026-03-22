resource "hcloud_server" "main" {
  name        = var.server_name
  image       = "debian-13"
  server_type = var.server_type
  location    = var.location
  
  firewall_ids = [var.firewall_id]

  network {
    network_id = var.network_id
  }

  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }

  user_data = templatefile("${path.module}/templates/cloud-init-base.yaml.tftpl", {
    admin_user = var.admin_user,
    ssh_key    = var.ssh_key
  })

  labels = {
    role = "docker-host"
    env  = "dev"
  }
}
