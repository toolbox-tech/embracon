module "key_vault" {
    source = "./modules/keyvault"

    key_vault_name          = "kv-dev-myapp"
    resource_group_name     = "var.resource_group_name"
    location                = "eastus"
    purge_protection_enabled = false

    # Acesso para GitHub Actions
    github_actions_object_id = ""

    # Managed Identities com acesso de leitura
    managed_identities = [
        "var.app_managed_identity_id"
    ]

    # Usuários/grupos com acesso específico
    user_access_policies = [
        {
        object_id = "var.dev_team_group_id"
        secret_permissions = ["Get", "List", "Set"]
        },
        {
        object_id = "var.security_team_group_id"
        secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Backup", "Restore"]
        key_permissions = ["Get", "List"]
        certificate_permissions = ["Get", "List"]
        }
    ]

    tags = {
        Environment = "Development"
        Project     = "MyApp"
    }
}