
variable "vm_name" {
    
}

variable "vm_subnet" {

}

variable "vm_ip_address" {

}

variable "ocp_domain" {

}

variable "cluster_id" {

}

provider "vcd" {
  version = "3.4.0"

}




resource "vcd_vm" "VirtualMachine" {
  
  org = "dae691dbea51489088e89e813ba339b9"
  vdc = "vmware-dc"
  name = var.vm_name

  catalog_name  = "Public Catalog"
  template_name = "RedHat-7-Template-Official"
  cpus          = "2"
  memory        = "8192"
  computer_name = var.vm_name

  network {
    name               = var.vm_subnet
    type               = "org"
	ip_allocation_mode = "MANUAL"
	ip                 = var.vm_ip_address
	connected          = "true"
	is_primary = true
  }

  connection {
    type     = "ssh"
	user     = "root"
	password = self.customization.0.admin_password
	host     = "52.117.143.172"
	}
  
  provisioner "file" {
    source      = "./script/linux_activation.sh"
	destination = "/tmp/linux_activation.sh"
  }
  provisioner "file" {
    source      = "./script/helper_install.sh"
	destination = "/tmp/helper_install.sh"
  }
    provisioner "file" {
    source      = "./script/ocp-config.sh"
	destination = "/tmp/ocp-config.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
	  "chmod +x /tmp/linux_activation.sh",
	  "chmod +x /tmp/helper_install.sh",
	  "chmod +x /tmp/ocp-config.sh",
      "rpm -ivh http://52.117.132.7/pub/katello-ca-consumer-latest.noarch.rpm",
	  "/tmp/linux_activation.sh",
	  "subscription-manager register --org=customer --activationkey=ic4v_shared_fe534526-5cfb-4d0c-b241-7f2b3774d1db --force",
	  "sleep 3",
      "subscription-manager repos --enable=rhel-7-server-extras-rpms",
      "yum -y install podman",
#	  "chmod +x /tmp/helper_install.sh",
      "yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm",
      "yum -y install ansible git",
	  "sleep 3",
      "git clone https://github.com/lballesterosm/ocp4-helpernode /tmp/ocp4-helpernode",
	  "echo --- > /tmp/ocp4-helpernode/vars.yaml",
	  "echo disk: sda >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo helper: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  name: \"${var.vm_name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  ipaddr: \"${var.vm_ip_address}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo dns: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  domain: \"${var.ocp_domain}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  clusterid: \"${var.cluster_id}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  forwarder1: \"8.8.8.8\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  forwarder2: \"8.8.4.4\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo dhcp: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  router: \"192.168.2.1\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  bcast: \"192.168.2.255\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  netmask: \"255.255.255.0\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  poolstart: \"192.168.2.7\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  poolend: \"192.168.2.20\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  ipid: \"192.168.2.0\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  netmaskid: \"255.255.255.0\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo bootstrap: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  name: \"bootstrap\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  ipaddr: \"192.168.2.7\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  macaddr: \"00:50:56:01:25:9f\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo masters: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"master-1\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"192.168.2.10\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"00:50:56:01:3c:8a\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"master-2\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"192.168.2.11\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"00:50:56:01:3c:8b\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"master-3\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"192.168.2.12\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"00:50:56:01:3c:8d\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo workers: >> /tmp/ocp4-helpernode/vars.yaml",	  
	  "echo \"  - name: \"worker1\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"192.168.2.8\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"00:50:56:01:3c:89\"\" >> /tmp/ocp4-helpernode/vars.yaml",	  
	  "echo \"  - name: \"worker2\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"192.168.2.9\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"00:50:56:01:3c:8c\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "sleep 3",
	  "cd /",
	  "cd /tmp/ocp4-helpernode",
	  "ansible-playbook -e @vars.yaml tasks/main.yml",
      "yum -y groupinstall \"Server with GUI\"",
      "systemctl set-default graphical.target",
      "/tmp/ocp-config.sh ${var.ocp_domain} ${var.cluster_id}",	  
	] 
  }
  

}

data "vcd_vm" "target_vm" {
   org = "dae691dbea51489088e89e813ba339b9"
   vdc = "vmware-dc"
   name     = var.vm_name
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