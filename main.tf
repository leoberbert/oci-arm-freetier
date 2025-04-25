provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

resource "oci_core_instance" "vm_instance" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = var.vm_name
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id                 = oci_core_subnet.subnet.id
    display_name              = "${var.vm_name}-vnic"
    assign_public_ip          = true
    assign_private_dns_record = true
    hostname_label            = lower(var.vm_name)
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("cloud-init.sh"))
  }

  timeouts {
    create = "60m"
  }
}

# Virtual Cloud Network
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name}-vcn"
  dns_label      = "${lower(var.vm_name)}vcn"
}

# Security List
resource "oci_core_security_list" "security_list" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.vm_name}-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    stateless   = false
  }

  ingress_security_rules {
    protocol  = "all"
    source    = "0.0.0.0/0"
    stateless = false
  }

  ingress_security_rules {
    protocol  = 1
    source    = "0.0.0.0/0"
    stateless = false

    icmp_options {
      type = 3
      code = 4
    }
  }
}

# Internet Gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name}-igw"
  vcn_id         = oci_core_vcn.vcn.id
}

# Route Table
resource "oci_core_default_route_table" "default_route_table" {
  manage_default_resource_id = oci_core_vcn.vcn.default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}

# Subnet
resource "oci_core_subnet" "subnet" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr
  display_name        = "${var.vm_name}-subnet"
  dns_label           = "${lower(var.vm_name)}subnet"
  security_list_ids   = [oci_core_security_list.security_list.id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn.id
  route_table_id      = oci_core_vcn.vcn.default_route_table_id
  dhcp_options_id     = oci_core_vcn.vcn.default_dhcp_options_id
}

# Availability Domain
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain
}

# Outputs
output "vm_public_ip" {
  value = oci_core_instance.vm_instance.public_ip
}

output "vm_private_ip" {
  value = oci_core_instance.vm_instance.private_ip
}

output "ssh_connection_string" {
  value = "ssh ubuntu@${oci_core_instance.vm_instance.public_ip}"
}

resource "local_file" "vm_info" {
  content = <<-EOT
    # Informações da VM ${var.vm_name}
    # Criada em: ${timestamp()}
    
    IP Público: ${oci_core_instance.vm_instance.public_ip}
    IP Privado: ${oci_core_instance.vm_instance.private_ip}
    Comando SSH: ssh ubuntu@${oci_core_instance.vm_instance.public_ip}
    
    Configuração:
    - Shape: ${var.shape}
    - OCPUs: ${var.ocpus}
    - Memória: ${var.memory_in_gbs} GB
    - Volume de Boot: ${var.boot_volume_size_in_gbs} GB
    
    ID da Instância: ${oci_core_instance.vm_instance.id}
    Zona de Disponibilidade: ${data.oci_identity_availability_domain.ad.name}
  EOT
  
  filename = "${abspath(path.root)}/vm_info_${formatdate("YYYY-MM-DD_HH-mm", timestamp())}.txt"
}
