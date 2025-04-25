# Oracle Cloud ARM Free Tier - Terraform

Este repositório contém arquivos Terraform para provisionar automaticamente uma VM ARM (VM.Standard.A1.Flex) na Oracle Cloud Infrastructure Free Tier.

## 📋 Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) instalado (versão 0.12 ou superior)
- Conta na [Oracle Cloud Infrastructure](https://www.oracle.com/cloud/free/)
- Chave SSH gerada no seu computador (`ssh-keygen -t rsa -b 2048`)
- Chave API configurada no OCI Console

## 🔑 Como configurar a chave API na Oracle Cloud

1. Faça login no console da Oracle Cloud: https://cloud.oracle.com
2. Acesse seu perfil de usuário: Clique no ícone de perfil > Meu perfil
3. No menu lateral esquerdo, clique em "Chaves API" ou acesse diretamente: https://cloud.oracle.com/identity/domains/my-profile/api-keys
4. Clique em "Adicionar chave API"
5. Você pode escolher:
   - Gerar automaticamente um par de chaves pelo console (opção mais simples)
   - Fazer upload da sua própria chave pública

### Opção 1: Geração pela Console OCI

1. No console OCI, acesse https://cloud.oracle.com/identity/domains/my-profile/api-keys
2. Clique em "Adicionar chave API"
3. Selecione "Gerar par de chaves API"
4. Clique em "Baixar chave privada" e salve o arquivo .pem
5. Clique em "Adicionar" para concluir
6. Anote a fingerprint que será exibida

### Opção 2: Gerando sua própria chave PEM e importando:

Se preferir gerar sua própria chave:

```bash
# Gerar a chave privada
openssl genrsa -out oci_api_key.pem 2048

# Gerar a chave pública a partir da privada
openssl rsa -pubout -in oci_api_key.pem -out oci_api_key_public.pem

# Adicionar a tag de segurança no final do arquivo da chave privada
echo "OCI_API_KEY" >> oci_api_key.pem

# Ajustar as permissões para mais segurança
chmod 600 oci_api_key.pem
```

Após gerar as chaves:
1. Copie o conteúdo do arquivo `oci_api_key_public.pem`
2. No Console OCI, clique em "Adicionar chave API" e escolha "Colar chave pública"
3. Cole o conteúdo da chave pública
4. Clique em "Adicionar"
5. Anote a fingerprint que será exibida

## ⚙️ Configuração

1. Clone este repositório:
   ```bash
   git clone https://github.com/leoberbert/oci-arm-freetier.git
   cd oci-arm-freetier
   ```

2. Edite o arquivo `terraform.tfvars` com suas informações:

   ```terraform
   # Informações da conta OCI
   tenancy_ocid     = "ocid1.tenancy.oc1..XXXXXXXXXXXX"  # https://cloud.oracle.com/tenancy
   user_ocid        = "ocid1.user.oc1..XXXXXXXXXXXXXXXX" # https://cloud.oracle.com/identity/domains/my-profile
   fingerprint      = "XX:XX:XX:XX:XX:XX:XX:X:XX:XX:XX:XX:XX:XX:XX:XX" # Da chave API
   private_key_path = "caminho/para/sua/chave_privada.pem" # Chave API privada
   region           = "sua_regiao" # Ex: sa-vinhedo-1, us-ashburn-1, etc.

   # O compartment_ocid - geralmente o mesmo valor de tenancy_ocid para contas Free Tier
   compartment_ocid = "ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxx"

   # Configuração da VM
   vm_name                = "meu_hostname" # Nome da sua VM
   shape                  = "VM.Standard.A1.Flex" # Não alterar para manter free tier
   ocpus                  = 4 # Máximo no free tier
   memory_in_gbs          = 24 # Máximo no free tier
   availability_domain    = 1 # Geralmente 1, mas pode variar por região
   boot_volume_size_in_gbs = 50 # Até 200GB no free tier

   # ID da imagem - Ubuntu 24.04 para ARM64
   image_id               = "ocid1.image.oc1.sa-vinhedo-1.aaaaaaaa2uccukdkrms7jkpuox7gxzqc76m4qoe6t4l5ighvzlwvrayjolda"

   # Cole aqui o conteúdo da sua chave SSH pública (cat ~/.ssh/id_rsa.pub)
   ssh_public_key         = "ssh-rsa AAAAB3Nza...."
   ```

3. (Opcional) Edite o arquivo `cloud-init.sh` para personalizar os pacotes a serem instalados ou removidos na VM durante a criação.

## 🚀 Uso

1. Inicialize o Terraform:
   ```bash
   terraform init
   ```

2. Visualize o plano de execução:
   ```bash
   terraform plan
   ```

3. Crie a infraestrutura:
   ```bash
   terraform apply
   ```
   Confirme a criação digitando `yes` quando solicitado.

4. Após a conclusão, os detalhes da VM serão exibidos no terminal e salvos em um arquivo com formato `vm_info_[DATA-HORA].txt` no diretório atual.

5. Conecte-se à VM usando o comando SSH mostrado na saída:
   ```bash
   ssh ubuntu@IP_PUBLICO_DA_VM
   ```

## 🗑️ Destruindo a infraestrutura

Para remover todos os recursos criados:

```bash
terraform destroy
```
Confirme a destruição digitando `yes` quando solicitado.

## ⚠️ Limitações do Free Tier da OCI

- Até 4 OCPUs ARM e 24GB de RAM
- Até 200GB de armazenamento em bloco
- Até 2 VMs Always Free
- Sempre use a shape `VM.Standard.A1.Flex` para permanecer dentro do free tier

## 📁 Arquivos do projeto

- `main.tf`: Definição dos recursos a serem criados
- `variables.tf`: Definição das variáveis utilizadas
- `terraform.tfvars`: Valores das variáveis
- `cloud-init.sh`: Script de inicialização executado na primeira inicialização da VM

## 🏗️ Recursos criados

- VM ARM com 4 OCPUs e 24GB de RAM
- VCN (Virtual Cloud Network)
- Subnet
- Internet Gateway
- Route Table
- Security List (permitindo todo tráfego de entrada e saída)

## 📝 Observações

- A VM criada terá um IP público por padrão
- As configurações de segurança permitem todo o tráfego de entrada e saída (modifique conforme suas necessidades)
- O tamanho do volume de boot é definido em `boot_volume_size_in_gbs`

## 🤝 Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## 📜 Licença

[MIT](LICENSE)
