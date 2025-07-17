data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azuread_group" "akv_access" {
  display_name     = var.ad_group_name
  security_enabled = true
  mail_nickname    = var.ad_group_name
}

resource "azurerm_user_assigned_identity" "aks_mi" {
  name                = var.managed_identity_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azuread_group_member" "mi_member" {
  group_object_id  = azuread_group.akv_access.id
  member_object_id = azurerm_user_assigned_identity.aks_mi.principal_id
}

resource "azurerm_key_vault" "main" {
  name                        = var.keyvault_name
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.aks_name}-dns"
  sku_tier            = "Free"

  default_node_pool {
    name       = "default"
    node_count = 1
    min_count  = 1
    max_count  = 3
    auto_scaling_enabled = true
    vm_size   = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled = true
}

resource "azapi_resource" "federated_credential" {
  type      = "Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2025-01-31-preview"
  name      = "kubernetes-federated-credential"
  parent_id = azurerm_user_assigned_identity.aks_mi.id

  body = jsonencode({
    name = "kubernetes-federated-credential"
    properties = {
      issuer = azurerm_kubernetes_cluster.aks.oidc_issuer_url
      subject = "system:serviceaccount:${var.namespace}:${var.service_account_name}"
      audiences = ["api://AzureADTokenExchange"]
    }
  })
}

resource "azurerm_role_assignment" "akv_secret_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_group.akv_access.object_id
}