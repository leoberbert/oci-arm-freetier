provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

# Novas variáveis para controle de VCN
variable "create_new_vcn" {
  description = "Define se deve criar uma nova VCN ou usar uma existente"
  type        = bool
  default     = true
}

variable "existing_vcn_id" {
  description = "ID da VCN existente, caso create_new_vcn seja false"
  type        = string
  default     = ""
}

variable "existing_subnet_id" {
  description = "ID da subnet existente, caso create_new_vcn seja false"
  type        = string
  default     = ""
}

# Availability Domain
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain
}

# Virtual Cloud Network - criado apenas se create_new_vcn for true
resource "oci_core_vcn" "vcn" {
  count          = var.create_new_vcn ? 1 : 0
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name}-vcn"
  dns_label      = "${lower(var.vm_name)}vcn"
}

# Data source para obter a VCN existente
data "oci_core_vcn" "existing_vcn" {
  count          = var.create_new_vcn ? 0 : 1
  vcn_id         = var.existing_vcn_id
}

# Security List - criada apenas se create_new_vcn for true
resource "oci_core_security_list" "security_list" {
  count          = var.create_new_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.vcn[0].id
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

# Internet Gateway - criado apenas se create_new_vcn for true
resource "oci_core_internet_gateway" "internet_gateway" {
  count          = var.create_new_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.vm_name}-igw"
  vcn_id         = oci_core_vcn.vcn[0].id
}

# Route Table - atualizada apenas se create_new_vcn for true
resource "oci_core_default_route_table" "default_route_table" {
  count                      = var.create_new_vcn ? 1 : 0
  manage_default_resource_id = oci_core_vcn.vcn[0].default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway[0].id
  }
}

# Subnet - criada apenas se create_new_vcn for true
resource "oci_core_subnet" "subnet" {
  count               = var.create_new_vcn ? 1 : 0
  availability_domain = data.oci_identity_availability_domain.ad.name
  cidr_block          = var.subnet_cidr
  display_name        = "${var.vm_name}-subnet"
  dns_label           = "${lower(var.vm_name)}subnet"
  security_list_ids   = [oci_core_security_list.security_list[0].id]
  compartment_id      = var.compartment_ocid
  vcn_id              = oci_core_vcn.vcn[0].id
  route_table_id      = oci_core_vcn.vcn[0].default_route_table_id
  dhcp_options_id     = oci_core_vcn.vcn[0].default_dhcp_options_id
}

# Data source para obter a subnet existente
data "oci_core_subnet" "existing_subnet" {
  count     = var.create_new_vcn ? 0 : 1
  subnet_id = var.existing_subnet_id
}

# VM Instance
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
    subnet_id                 = var.create_new_vcn ? oci_core_subnet.subnet[0].id : var.existing_subnet_id
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
    user_data           = base64encode(file("cloud-config.yaml"))
  }

  timeouts {
    create = "60m"
  }
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

output "vcn_id" {
  value = var.create_new_vcn ? oci_core_vcn.vcn[0].id : var.existing_vcn_id
  description = "ID da VCN usada (criada ou existente)"
}

output "subnet_id" {
  value = var.create_new_vcn ? oci_core_subnet.subnet[0].id : var.existing_subnet_id
  description = "ID da subnet usada (criada ou existente)"
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
    
    # Informações de Rede
    VCN ID: ${var.create_new_vcn ? oci_core_vcn.vcn[0].id : var.existing_vcn_id}
    Subnet ID: ${var.create_new_vcn ? oci_core_subnet.subnet[0].id : var.existing_subnet_id}
    VCN Criada: ${var.create_new_vcn ? "Sim" : "Não (usando existente)"}
  EOT

  filename = "${abspath(path.root)}/vm_info_${formatdate("YYYY-MM-DD_HH-mm", timestamp())}.txt"
}
