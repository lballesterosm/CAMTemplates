
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
  user      = "admin"
  password  = "JeNDT5CXQUVSJJrKT"
  version   = "3.4.0"
  org       = "dae691dbea51489088e89e813ba339b9"
  url       = "https://daldir01.vmware-solutions.cloud.ibm.com/api"  
}

resource "vcd_vm" "VirtualMachine" {
  count = var.cantidad
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = var.vm_1_prefix${count.index}

  catalog_name  = "Public Catalog"
  template_name = var.vm_1_image
  cpus          = var.vm_1_vcpu
  memory        = var.vm_1_memory
  computer_name = var.vm_1_name

  network {
    name               = var.vm_1_subnet
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }


}

data "vcd_vm" "target_vm" {
   org = "dae691dbea51489088e89e813ba339b9"
   vdc = "vmware-dc"
   name     = var.vm_1_name
   depends_on = [
     vcd_vm.VirtualMachine
   ]
}

output "vm_password" {
  value = data.vcd_vm.target_vm.customization.*.admin_password
}
output "vm_ip" {
  description = "VM IP address"
  value = data.vcd_vm.target_vm.network.*.ip
}

output "vm_mac" {
  description = "MAC IP address"
  value = data.vcd_vm.target_vm.network.*.mac
}