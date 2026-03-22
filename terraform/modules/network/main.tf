resource "hcloud_network" "main" {
  name     = var.network_name
  ip_range = var.ip_range
}

resource "hcloud_network_subnet" "main" {
  network_id   = hcloud_network.main.id
  type         = "cloud"
  network_zone = var.network_zone
  ip_range     = var.subnet_range
}
