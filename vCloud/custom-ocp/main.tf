provider "vcd" {
  user      = "admin"
  password  = "JeNDT5CXQUVSJJrKT"
  auth_type = "integrated"
  org       = "dae691dbea51489088e89e813ba339b9"
  url       = "https://daldir01.vmware-solutions.cloud.ibm.com/api"
  max_retry_timeout = "120"
  allow_unverified_ssl = "true"

}



variable "cantidad" {
  type = string
  default = "2"
}

variable "vm_vcpu" {
  type = string
  default = "2"  
}
variable "vm_memory" {
  type = string
  default = "2048"
    
}

variable "vm_subnet" {
  type = string
  default = "prod"
}

variable "cluster_id" {
  type = string
  default = "my-ocp"
}

variable "vm_ip_address" {
  type = string
  default = "192.168.2.50"
}


variable "vm_name" {
  type = string
  default = "helperserver3"
}

variable "ocp_domain" {
  type = string
  default = "example.com"
}

resource "vcd_vm" "bootstrap" {
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = "${var.cluster_id}-b"

  cpus          = "2"
  cpu_cores     = "1"
  memory        = "4096"
  catalog_name  = "Public Catalog"
  os_type       = "coreos64Guest"
  computer_name = "${var.cluster_id}-b"
  hardware_version = "vmx-13"

  network {
    name               = "prod"
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }
  
 power_on = false

}

resource "vcd_vm_internal_disk" "bootstrap_disk" {
  org             = "dae691dbea51489088e89e813ba339b9"
  vdc             = "vmware-dc"
  vapp_name       = vcd_vm.bootstrap.vapp_name
  vm_name         = vcd_vm.bootstrap.name
  bus_type        = "paravirtual"
  size_in_mb      = "32768"
  bus_number      = "0"
  unit_number     = "0"
  storage_profile = "Standard"
  
  depends_on = [
    vcd_vm.bootstrap
  ]
}

resource "vcd_vm" "masters" {
  count = "3"
  org = "dae691dbea51489088e89e813ba339b9"
  vdc = "vmware-dc"
  name = "${var.cluster_id}-m-${count.index+1}"

  catalog_name     = "Public Catalog"
  os_type          = "coreos64Guest"
  hardware_version = "vmx-13"
  cpus             = "4"
  cpu_cores        = "2"
  memory           = "8192"
  computer_name    = "${var.cluster_id}-m-${count.index+1}"

  network {
    name               = "prod"
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }
  power_on = false
   depends_on = [
    vcd_vm_internal_disk.bootstrap_disk
  ]
}

resource "vcd_vm_internal_disk" "masters_disk" {
  count           = "3"
  org             = "dae691dbea51489088e89e813ba339b9"
  vdc             = "vmware-dc"
  vapp_name       = vcd_vm.masters[count.index].vapp_name
  vm_name         = vcd_vm.masters[count.index].name
  bus_type        = "paravirtual"
  size_in_mb      = "40960"
  bus_number      = "0"
  unit_number     = "0"
  storage_profile = "Standard"
  
  depends_on = [
    vcd_vm.masters
  ]
}


resource "vcd_vm" "workers" {
  count = var.cantidad
  org = "dae691dbea51489088e89e813ba339b9"
  vdc = "vmware-dc"
  name = "${var.cluster_id}-w-${count.index+1}"

  catalog_name     = "Public Catalog"
  os_type          = "coreos64Guest"
  hardware_version = "vmx-13"
  cpus             = var.vm_vcpu
  cpu_cores        = "1"  
  memory           = var.vm_memory
  computer_name    = "${var.cluster_id}-w-${count.index+1}"

  network {
    name               = "prod"
    type               = "org"
	ip_allocation_mode = "POOL"
	is_primary = true
  }
  power_on = false
  depends_on = [
    vcd_vm_internal_disk.masters_disk
  ]
}

resource "vcd_vm_internal_disk" "workers_disk" {
  count           = var.cantidad
  org             = "dae691dbea51489088e89e813ba339b9"
  vdc             = "vmware-dc"
  vapp_name       = vcd_vm.workers[count.index].vapp_name
  vm_name         = vcd_vm.workers[count.index].name
  bus_type        = "paravirtual"
  size_in_mb      = "40960"
  bus_number      = "0"
  unit_number     = "0"
  storage_profile = "Standard"
  
  depends_on = [
    vcd_vm.workers
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

resource "vcd_vm" "helperserver" {
  org   = "dae691dbea51489088e89e813ba339b9"
  vdc   = "vmware-dc"
  name  = var.vm_name

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
    source      = "./scripts/linux_activation.sh"
	destination = "/tmp/linux_activation.sh"
  }
  provisioner "file" {
    source      = "./scripts/helper_install.sh"
	destination = "/tmp/helper_install.sh"
  }
    provisioner "file" {
    source      = "./scripts/ocp-config.sh"
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
	  "echo \"  poolstart: \"192.168.2.2\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  poolend: \"192.168.2.50\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  ipid: \"192.168.2.0\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  netmaskid: \"255.255.255.0\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo bootstrap: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  name: \"${vcd_vm.bootstrap.name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  ipaddr: \"${vcd_vm.bootstrap.network.0.ip}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  macaddr: \"${vcd_vm.bootstrap.network.0.mac}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo masters: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"${vcd_vm.masters[0].name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"${vcd_vm.masters[0].network.0.ip}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"${vcd_vm.masters[0].network.0.mac}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"${vcd_vm.masters[1].name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"${vcd_vm.masters[1].network.0.ip}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"${vcd_vm.masters[1].network.0.mac}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"${vcd_vm.masters[2].name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"${vcd_vm.masters[2].network.0.ip}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"${vcd_vm.masters[2].network.0.mac}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo workers: >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"  - name: \"${vcd_vm.workers[0].name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"${vcd_vm.workers[0].network.0.ip}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"${vcd_vm.workers[0].network.0.mac}\"\" >> /tmp/ocp4-helpernode/vars.yaml",	  
	  "echo \"  - name: \"${vcd_vm.workers[1].name}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    ipaddr: \"${vcd_vm.workers[1].network.0.ip}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "echo \"    macaddr: \"${vcd_vm.workers[1].network.0.mac}\"\" >> /tmp/ocp4-helpernode/vars.yaml",
	  "sleep 3",
	  "cd /tmp/ocp4-helpernode",
	  "ansible-playbook -e @vars.yaml tasks/main.yml",
#      "yum -y groupinstall \"Server with GUI\"",
#      "systemctl set-default graphical.target",
#      "/tmp/ocp-config.sh ${var.ocp_domain} ${var.cluster_id}",
      "cd /tmp",
	  "mkdir /tmp/${var.cluster_id}",
      "mkdir /tmp/${var.cluster_id}-bkp",
	  "cd /tmp/${var.cluster_id}",
      "echo \"apiVersion: v1\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"baseDomain: ${var.ocp_domain}\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo compute: >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo - hyperthreading: Enabled >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  name: worker\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  replicas: 2\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo controlPlane: >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  hyperthreading: Enabled\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  name: master\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  replicas: 3\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo metadata: >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  name: ${var.cluster_id}\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo networking: >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  clusterNetworks:\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  - cidr: 10.254.0.0/16\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"    hostPrefix: 24\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  networkType: OpenShiftSDN\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  serviceNetwork:\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  - 172.30.0.0/16\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo platform: >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"  none: {}\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"pullSecret: '$(< /tmp/ocp4-helpernode/pull-secret/pull-secret)'\" >>/tmp/${var.cluster_id}/install-config.yaml",
      "echo \"sshKey: '$(< /tmp/.ssh/helper_rsa.pub)'\" >>/tmp/${var.cluster_id}/install-config.yaml",
#      "echo cp /tmp/${var.cluster_id}/install-config.yaml /tmp/${var.cluster_id}-bkp/install-config.yaml",
      "cp install-config.yaml /tmp/${var.cluster_id}-bkp/install-config.yaml",
      "openshift-install create manifests",
      "sleep 3",
      "openshift-install create ignition-configs",
      "sleep 3",
      "cp *.ign /var/www/html/ignition/",
      "restorecon -vR /var/www/html",
      "chmod o+r /var/www/html/ignition/*.ign",
	  ]
	}
    depends_on = [
      vcd_vm.workers,
	  vcd_vm.masters,
	  vcd_vm.bootstrap,
    ]

}

data "vcd_vm" "target_vm" {
   org = "dae691dbea51489088e89e813ba339b9"
   vdc = "vmware-dc"
   name     = var.vm_name
   depends_on = [
     vcd_vm.helperserver
   ]
}


output "vm_password" {
  value = data.vcd_vm.target_vm.customization.*.admin_password
}
output "vm_ip" {
  description = "VM IP address"
  value = data.vcd_vm.target_vm.network.*.ip
}