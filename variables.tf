# Variáveis do provedor OCI
variable "tenancy_ocid" {
  description = "OCID da tenancy"
  type        = string
}

variable "user_ocid" {
  description = "OCID do usuário"
  type        = string
}

variable "fingerprint" {
  description = "Fingerprint da chave API"
  type        = string
}

variable "private_key_path" {
  description = "Caminho para a chave privada"
  type        = string
}

variable "region" {
  description = "Região OCI"
  type        = string
  default     = "sa-vinhedo-1"
}

variable "compartment_ocid" {
  description = "OCID do compartment"
  type        = string
}

# Variáveis da VM
variable "vm_name" {
  description = "Nome da VM"
  type        = string
  default     = "MyVM"
}

variable "shape" {
  description = "Shape da VM"
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "Número de OCPUs"
  type        = number
  default     = 4
}

variable "memory_in_gbs" {
  description = "Memória em GBs"
  type        = number
  default     = 24
}

variable "availability_domain" {
  description = "Número da availability domain"
  type        = number
  default     = 1
}

variable "boot_volume_size_in_gbs" {
  description = "Tamanho do boot volume em GBs"
  type        = number
  default     = 100
}

variable "image_id" {
  description = "OCID da imagem"
  type        = string
}

variable "ssh_public_key" {
  description = "Chave SSH pública para acesso à VM"
  type        = string
}

# Variáveis de rede
variable "vcn_cidr" {
  description = "CIDR block para a VCN"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block para a subnet"
  type        = string
  default     = "10.0.0.0/24"
}
