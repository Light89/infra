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
  for_each     = var.servers
  source       = "../../modules/server"
  server_name  = each.key
  server_type  = each.value.server_type
  location     = each.value.location
  network_id   = module.network.network_id
  firewall_id  = module.firewall.firewall_id
  admin_user     = "ansible"
  ssh_public_key = var.ssh_public_key
  server_role    = each.value.role
  
  depends_on = [
    module.network,
    module.firewall
  ]
}

output "server_ips" {
  value = { for k, v in module.server : k => v.public_ip }
}
