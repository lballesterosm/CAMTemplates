
variable "cantidad" {

}

variable "vm_1_vcpu" {
    
}
variable "vm_1_memory" {
    
}

variable "vm_1_subnet" {

}


provider "vcd" {
  version = "3.4.0"

}


resource "vcd_vm" "bootstrap" {
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = "bootstrap"

  catalog_name  = "Public Catalog"
  template_name = "rhcos OpenShift 4.8.14"
  cpus          = "2"
  memory        = "4096"
  computer_name = "bootstrap"

  network {
    name               = var.vm_1_subnet
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }
 power_on = false

}

resource "vcd_vm" "masters" {
  count = 3
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = "master-${count.index+1}"

  catalog_name  = "Public Catalog"
  template_name = "rhcos OpenShift 4.8.14"
  cpus          = "4"
  memory        = "8192"
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


output "masters_info" {
  value = "${formatlist(
    "%s = %s, %s", 
    vcd_vm.masters[*].name,
    vcd_vm.masters[*].network.0.ip,
	vcd_vm.masters[*].network.0.mac
  )}"

    depends_on = [
      vcd_vm.masters
    ]
}

output "workers_info" {
  value = "${formatlist(
    "%s = %s, %s", 
    vcd_vm.workers[*].name,
    vcd_vm.workers[*].network.0.ip,
	vcd_vm.workers[*].network.0.mac
  )}"

    depends_on = [
      vcd_vm.workers
    ]
}

output "bootstrap_info" {
  value = "${formatlist(
    "%s = %s, %s", 
    vcd_vm.bootstrap.name,
    vcd_vm.bootstrap.network.0.ip,
	vcd_vm.bootstrap.network.0.mac
  )}"

    depends_on = [
      vcd_vm.bootstrap
    ]
}