terraform {
  required_providers {
    vcd = {
      version = "3.4.0"
    }
  }
}

variable "vm_1_name" {
    
}
variable "vm_1_vcpu" {
    
}
variable "vm_1_memory" {
    
}
variable "vm_1_image" {
    
}


provider "vcd" {
  user      = "admin"
  password  = "JeNDT5CXQUVSJJrKT"
  auth_type = "integrated"
  org       = "dae691dbea51489088e89e813ba339b9"
  url       = "https://daldir01.vmware-solutions.cloud.ibm.com/api"
  max_retry_timeout = "120"
  allow_unverified_ssl = "true"

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
    name               = "my-net"
    type               = "org"
	ip_allocation_mode = "DHCP"
	is_primary = true
  }

  customization {
    allow_local_admin_password = true
    auto_generate_password     = false
    admin_password             = "Acero2018"
    # Other customization options to override the ones from template
  }

}