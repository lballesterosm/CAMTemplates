# This is a terraform generated template generated from blueprint89


##############################################################
# Define the vcd provider 
##############################################################

provider "vcd" {
}

provider "camc" {
  version = "~> 0.2"
}

##############################################################
# Vsphere data for provider
##############################################################

data "vcd_network_routed" "net" {
  name     = "my-net"
  type      = "org"
  
  
}

data "vsphere_virtual_machine" "vm_1_template" {
  name          = var.vm_1-image
  
}

##### Image Parameters variables #####

#Variable : vm_1_name
variable "vm_1_name" {
  type        = string
  description = "Generated"
  default     = "vm_1"
}

#########################################################
##### Resource : vm_1
#########################################################

variable "vm_1_number_of_vcpu" {
  description = "Number of virtual CPU for the virtual machine, which is required to be a positive Integer"
  default     = "1"
}

variable "vm_1_memory" {
  description = "Memory assigned to the virtual machine in megabytes. This value is required to be an increment of 1024"
  default     = "1024"
}

variable "vm_1-image" {
  description = "Operating system image id / template that should be used when creating the virtual image"
}

# vsphere vm
resource "vcd_vm" "vm_1" {
  org              = "dae691dbea51489088e89e813ba339b9"
  vdc              = "vmware-dc"
  name             = var.vm_1_name
  catalog_name     = "Public Catalog"
  template_name    = var.vm_1-image
  num_cpus         = var.vm_1_number_of_vcpu
  memory           = var.vm_1_memory

  network {
      name = data.vcd_network_routed.name
      type = data.vcd_network_routed.type
      ip_allocation_mode = "DHCP"
      is_primary = true
  }  

}