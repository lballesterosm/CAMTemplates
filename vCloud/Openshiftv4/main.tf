
variable "vm_1_vcpu" {
    
}
variable "vm_1_memory" {
    
}

variable "vm_1_subnet" {

}


provider "vcd" {
  version = "3.4.0"

}

resource "vcd_vm" "masters" {
  count = 3
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = "master-${count.index+1}"

  catalog_name  = "Public Catalog"
  template_name = "rhcos OpenShift 4.8.14"
  cpus          = "4"
  memory        = "8"
  computer_name = "master-${count.index+1}"

  network {
    name               = var.vm_1_subnet
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }
 power_on = false

}

resource "vcd_vm" "workers" {
  count = var.cantidad
  org = "dae691dbea51489088e89e813ba339b9"
  vdc = "vmware-dc"
  name = "worker${count.index+1}"

  template_name    = "rhcos OpenShift 4.8.14"
  catalog_name     = "Public Catalog"
  cpus             = var.vm_1_vcpu
  memory           = var.vm_1_memory
  computer_name    = "worker${count.index+1}"

  network {
    name               = var.vm_1_subnet
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }
  power_on = false
}

