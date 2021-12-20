
variable "vm_1_name" {
    
}
variable "vm_1_vcpu" {
    
}
variable "vm_1_memory" {
    
}
variable "vm_1_image" {
    
}

variable "vm_1_subnet" {

}


provider "vcd" {
  version = "3.4.0"

}

 resource "vcd_vm" "VirtualMachine" {
  
  org = "dae691dbea51489088e89e813ba339b9"
  vdc = "vmware-dc"
  name = var.vm_1_name

  catalog_name  = "Public Catalog"
  template_name = var.vm_1_image
  cpus          = var.vm_1_vcpu
  memory        = var.vm_1_memory

  network {
    name               = var.vm_1_subnet
    type               = "org"
	ip_allocation_mode = "DHCP"
	is_primary = true
  }

}
