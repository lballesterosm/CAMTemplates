# Configure the IBM Provider
provider "ibm" {
  region = "us-south"
}

# Variables

variable "power_instance_name" {

}

variable "power_replicas" {

}

variable "power_vm_pinning" {

}

variable "power_placement_group" {

}

variable "power_ssh_key" {

}

variable "power_image" {

}

variable "power_network" {

}

variable "power_machine_type" {

}

variable "power_core_type" {

}

variable "power_cores" {

}

variable "power_memory" {

}



# Create a Power virtual server instance
resource "ibm_pi_instance" "test-instance" {
    pi_instance_name      = var.power_instance_name
    pi_memory             = var.power_memory
    pi_processors         = var.power_cores
        pi_proc_type          = var.power_core_type
    pi_image_id           = var.power_image
    pi_key_pair_name      = var.power_ssh_key
    pi_sys_type           = var.power_machine_type
    pi_pin_policy         = var.power_vm_pinning
    
    pi_network {
      network_id = var.power_network
    }
}
