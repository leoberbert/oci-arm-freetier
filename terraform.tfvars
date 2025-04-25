# Informações da conta OCI
tenancy_ocid     = "ocid1.tenancy.oc1..XXXXXXXXXXXX" - https://cloud.oracle.com/tenancy
user_ocid        = "ocid1.user.oc1..XXXXXXXXXXXXXXXX" - https://cloud.oracle.com/identity/domains/my-profile
# Fingerprint da chave importada em API keys na Console da OCI - https://cloud.oracle.com/identity/domains/my-profile/api-keys
fingerprint      = "XX:XX:XX:XX:XX:XX:XX:X:XX:XX:XX:XX:XX:XX:XX:XX"
# Chave importada em API keys na Console da OCI - https://cloud.oracle.com/identity/domains/my-profile/api-keys
private_key_path = "chave_public.pem"
region           = "minha_regiao"

# O compartment_ocid - Mesmo valor de tenancy_ocid
compartment_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxx"

# Configuração da VM
vm_name                = "meu_hostname"
shape                  = "VM.Standard.A1.Flex"
ocpus                  = 4
memory_in_gbs          = 24
availability_domain    = 1
boot_volume_size_in_gbs = 50

# ID da imagem que você forneceu (Ubuntu 24.04.2 LTS)
image_id               = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa2uccukdkrms7jkpuox7gxzqc76m4qoe6t4l5ighvzlwvrayjolda"

# Substitua pelo conteúdo da sua chave SSH pública (cat ~/.ssh/id_rsa.pub)
ssh_public_key         = "ssh-rsa XXXXXXXXXXXXXXXXXXXXXXXX"
