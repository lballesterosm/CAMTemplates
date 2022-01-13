
variable "vm_1_name" {
    
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
  template_name = "New-RedHat-7-Template-Official"
  cpus          = "2"
  memory        = "8192"
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