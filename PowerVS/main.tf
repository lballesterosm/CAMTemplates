terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version = "~> 1.12.0"
    }
  }
}

# Configure the IBM Provider
provider "ibm" {
  region = "us-south"
}

# Variables

variable "test_key_1" {

}

# Create an IBM Cloud infrastructure SSH key. You can find the SSH key surfaces in the infrastructure console under Devices > Manage > SSH Keys
resource "ibm_compute_ssh_key" "test_key_1" {
  label      = "test_key_1"
  public_key = var.ssh_public_key
}

# Create a virtual server with the SSH key
resource "ibm_compute_vm_instance" "lpar" {
  hostname          = "host-b.example.com"
  domain            = "example.com"
  ssh_key_ids       = [123456, ibm_compute_ssh_key.test_key_1.id]
  os_reference_code = "CENTOS_6_64"
  datacenter        = "dal10"
  network_speed     = 10
  cores             = 1
  memory            = 1024
}