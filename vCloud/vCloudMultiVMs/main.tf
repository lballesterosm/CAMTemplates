provider "vcd" {
  user      = "admin"
  password  = "JeNDT5CXQUVSJJrKT"
  version   = "3.4.0"
  org       = "dae691dbea51489088e89e813ba339b9"
  url       = "https://daldir01.vmware-solutions.cloud.ibm.com/api"  
}


variable "vm_name" {
    
}
variable "vm_vcpu" {
    
}
variable "vm_memory" {
    
}
variable "vm_image" {
    
}

variable "vm_subnet" {

}

variable "cantidad" {

}


resource "vcd_vm" "VirtualMachine" {
  count = var.cantidad
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = "${var.vm_name}-${count.index+1}"
  
  catalog_name  = "Public Catalog"
  template_name = var.vm_image
  cpus          = var.vm_vcpu
  memory        = var.vm_memory
  computer_name = var.vm_name

  network {
    name               = var.vm_subnet
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }


}


output "vms_info" {
  value = "${formatlist(
    "%s = %s, %s", 
    vcd_vm.VirtualMachine[*].name,
    vcd_vm.VirtualMachine[*].network.0.ip,
	vcd_vm.VirtualMachine[*].network.0.mac
  )}"

    depends_on = [
      vcd_vm.VirtualMachine
    ]
}