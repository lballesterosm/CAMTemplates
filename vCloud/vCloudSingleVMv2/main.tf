
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

variable "vm_1_password" {

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
	ip_allocation_mode = "POOL"
	is_primary = true
  }

  customization {
    allow_local_admin_password = true 
    auto_generate_password     = false
    admin_password             = var.vm_1_password
  }
  
}

data "vcd_vm" "target_vm" {
   org = "dae691dbea51489088e89e813ba339b9"
   vdc = "vmware-dc"
   name     = var.vm_1_name
}


output "vm_details" {
  value = data.vcd_vm.target_vm
}