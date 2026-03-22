module "network" {
  source       = "../../modules/network"
  network_name = "dev-net"
  ip_range     = "10.1.0.0/16"
  subnet_range = "10.1.1.0/24"
  network_zone = "eu-central"
}

module "firewall" {
  source          = "../../modules/firewall"
  firewall_name   = "dev-default-fw"
  allowed_ssh_ips = var.allowed_ssh_ips
}

module "server" {
  source       = "../../modules/server"
  server_name  = "dev-docker-01"
  server_type  = "cx23"
  location     = "nbg1"
  network_id   = module.network.network_id
  firewall_id  = module.firewall.firewall_id
  admin_user     = "ansible"
  ssh_public_key = var.ssh_public_key
  
  depends_on = [
    module.network,
    module.firewall
  ]
}

output "server_ip" {
  value = module.server.public_ip
}
