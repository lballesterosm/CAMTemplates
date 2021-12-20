provider "vcd" {
  version = "3.4.0"

}
variable "subnet_name" {

}

variable "dhcp_start_ip" {

}
variable "dhcp_end_ip" {

}

variable "edge_gw" {

}

variable "dns_1" {

}

resource "vcd_network_routed" "net" {
  org = "dae691dbea51489088e89e813ba339b9"
  vdc ="vmware-dc"
  name = var.subnet_name
  edge_gateway = var.edge_gw
  gateway = "172.168.2.1"
  dns1 = "172.168.2.1"
  
  
  dhcp_pool {
    start_address = var.dhcp_start_ip
    end_address   = var.dhcp_end_ip
  }

}