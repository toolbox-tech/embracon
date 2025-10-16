# ===============================================
# Exemplo: Azure Key Vault com Usuários por Email
# ===============================================
# Este exemplo demonstra como usar o módulo para:
# 1. Criar um Azure Key Vault
# 2. Definir usuários usando emails (conversão automática)
# 3. Combinar usuarios diretos (principal_id) + emails
# 4. Monitorar os resultados via outputs

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configuração do provider Azure
provider "azurerm" {
  features {}
}

# ===============================================
# Resource Group (se não existir)
# ===============================================
resource "azurerm_resource_group" "example" {
  name     = "rg-keyvault-email-example"
  location = "Brazil South"

  tags = {
    Environment = "Demo"
    Purpose     = "Email-to-Principal-ID Example"
    CreatedBy   = "Terraform"
  }
}

# ===============================================
# Exemplo 1: Key Vault apenas com emails
# ===============================================
module "key_vault_emails_only" {
  source = "../module"

  # Configurações básicas
  key_vault_name      = "kv-emails-only-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Usuários identificados por email
  users_allowed_emails = [
    "marcelo.buzzetti@joaopereiratbxtech.onmicrosoft.com"
  ]
}

# ===============================================
# Exemplo 2: Key Vault combinando principal_ids + emails  
# ===============================================
module "key_vault_mixed" {
  source = "../module"

  # Configurações básicas
  key_vault_name      = "kv-mixed-users-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Usuários com principal_ids conhecidos
  users_allowed = [
    "d6369133-a12b-4f42-bd17-e136c620d630"
  ]

  # Usuários identificados por email (convertidos automaticamente)
  users_allowed_emails = [
    "marcelo.buzzetti@joaopereiratbxtech.onmicrosoft.com"
  ]
}

# ===============================================
# Exemplo 3: Key Vault apenas com principal_ids (tradicional)
# ===============================================
module "key_vault_traditional" {
  source = "../module"

  # Configurações básicas
  key_vault_name      = "kv-traditional-${random_string.suffix.result}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  # Apenas usuários com principal_ids
  users_allowed = [
    "d6369133-a12b-4f42-bd17-e136c620d630"
  ]
}

# ===============================================
# Recursos auxiliares
# ===============================================
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# ===============================================
# OUTPUTS - Informações dos Key Vaults criados
# ===============================================

# Exemplo 1: Key Vault apenas com emails
output "emails_only_vault_info" {
  description = "Informações do Key Vault criado apenas com emails"
  value = {
    vault_name = module.key_vault_emails_only.key_vault_name
    vault_uri  = module.key_vault_emails_only.key_vault_uri
    vault_id   = module.key_vault_emails_only.key_vault_id
  }
}

output "emails_only_users_processed" {
  description = "Usuários processados via conversão de email"
  value       = module.key_vault_emails_only.users_from_emails
  sensitive   = false
}

# Exemplo 2: Key Vault combinando principal_ids + emails
output "mixed_vault_info" {
  description = "Informações do Key Vault com usuários mistos"
  value = {
    vault_name = module.key_vault_mixed.key_vault_name
    vault_uri  = module.key_vault_mixed.key_vault_uri
    vault_id   = module.key_vault_mixed.key_vault_id
  }
}

output "mixed_users_processed" {
  description = "Usuários processados via conversão de email (vault misto)"
  value       = module.key_vault_mixed.users_from_emails
  sensitive   = false
}

output "mixed_all_principal_ids" {
  description = "Todos os principal_ids combinados (diretos + convertidos)"
  value       = module.key_vault_mixed.all_principal_ids
  sensitive   = false
}

output "mixed_direct_principal_ids" {
  description = "Principal_ids fornecidos diretamente (vault misto)"
  value       = module.key_vault_mixed.direct_principal_ids
  sensitive   = false
}

# Exemplo 3: Key Vault tradicional (apenas principal_ids)
output "traditional_vault_info" {
  description = "Informações do Key Vault tradicional"
  value = {
    vault_name = module.key_vault_traditional.key_vault_name
    vault_uri  = module.key_vault_traditional.key_vault_uri
    vault_id   = module.key_vault_traditional.key_vault_id
  }
}

output "traditional_direct_principal_ids" {
  description = "Principal_ids do vault tradicional"
  value       = module.key_vault_traditional.direct_principal_ids
  sensitive   = false
}

# ===============================================
# OUTPUTS - Resumo comparativo
# ===============================================
output "summary" {
  description = "Resumo comparativo dos três exemplos"
  value = {
    emails_only = {
      emails_provided = length(module.key_vault_emails_only.users_from_emails.emails)
      vault_name      = module.key_vault_emails_only.key_vault_name
    }
    mixed_users = {
      direct_principal_ids = length(module.key_vault_mixed.direct_principal_ids)
      emails_converted     = length(module.key_vault_mixed.users_from_emails.emails)
      total_users          = length(module.key_vault_mixed.all_principal_ids)
      vault_name           = module.key_vault_mixed.key_vault_name
    }
    traditional = {
      direct_principal_ids = length(module.key_vault_traditional.direct_principal_ids)
      vault_name           = module.key_vault_traditional.key_vault_name
    }
  }
}

# ===============================================
# COMANDO PARA EXECUÇÃO
# ===============================================
# terraform init
# terraform plan
# terraform apply
# 
# Para ver informações específicas:
# terraform output emails_only_users_processed
# terraform output mixed_all_principal_ids
# terraform output mixed_users_processed
# terraform output summary

provider "azurerm" {
  skip_provider_registration = true
  features {}
}

resource "azurerm_linux_virtual_machine" "my_linux_vm" {
  location = "eastus"
  name = "test"
  resource_group_name = "test"
  admin_username = "testuser"
  admin_password = "Testpa5s"

  size = "Standard_F16s" # <<<<<<<<<< Try changing this to Standard_F16s_v2 to compare the costs

  tags = {
    Environment = "production"
    Service = "web-app"
  }

  os_disk {
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface_ids = [
    "/subscriptions/123/resourceGroups/testrg/providers/Microsoft.Network/networkInterfaces/testnic",
  ]

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "16.04-LTS"
    version = "latest"
  }
}

resource "azurerm_service_plan" "my_app_service" {
  location = "eastus"
  name = "test"
  resource_group_name = "test_resource_group"
  os_type = "Windows"

  sku_name = "P1v2"
  worker_count = 4 # <<<<<<<<<< Try changing this to 8 to compare the costs

  tags = {
    Environment = "Prod"
    Service = "web-app"
  }
}

resource "azurerm_linux_function_app" "my_function" {
  location = "eastus"
  name = "test"
  resource_group_name = "test"
  service_plan_id = "/subscriptions/123/resourceGroups/testrg/providers/Microsoft.Web/serverFarms/serverFarmValue"
  storage_account_name = "test"
  storage_account_access_key = "test"
  site_config {}

  tags = {
    Environment = "Prod"
  }
}