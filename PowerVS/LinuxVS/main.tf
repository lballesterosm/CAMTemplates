# Configure the IBM Provider
provider "ibm" {
  region = "us-south"
  zone   = "dal10"
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

data "ibm_pi_network" "power_networks" {
    count                = "${length(var.power_network)}"
    pi_network_name      = "${var.power_network[count.index]}"
    pi_cloud_instance_id = "c2af394e-33b8-4154-9275-f69f5d65dc0d"
}

# Create a Power virtual server instance
resource "ibm_pi_instance" "VirtualServerInstance" {
    pi_instance_name      = var.power_instance_name
    pi_memory             = var.power_memory
    pi_processors         = var.power_cores
    pi_proc_type          = var.power_core_type
    pi_image_id           = var.power_image
    pi_key_pair_name      = var.power_ssh_key
    pi_sys_type           = var.power_machine_type
    pi_pin_policy         = var.power_vm_pinning
    pi_cloud_instance_id  = "c2af394e-33b8-4154-9275-f69f5d65dc0d"
    pi_network_ids        = ["${data.ibm_pi_network.power_networks.*.networkid}"]
    pi_replicants         = var.power_replicas
    

}
