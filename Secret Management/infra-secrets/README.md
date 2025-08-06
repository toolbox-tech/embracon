# Módulo Terraform: Azure Key Vault (AKV)

Este módulo facilita a criação e o gerenciamento de um **Azure Key Vault** (AKV) utilizando Terraform, permitindo integração segura de segredos, chaves e certificados em sua infraestrutura como código.

## Funcionalidades

- Criação automatizada de um Azure Key Vault.
- Suporte a gerenciamento de segredos, chaves e certificados.
- Controle de acesso via IAM e políticas de acesso granular.
- Pronto para integração com aplicações e pipelines CI/CD.

## Pré-requisitos

- Conta Azure com permissões para criar recursos.
- [Azure CLI](https://docs.microsoft.com/pt-br/cli/azure/install-azure-cli) instalado e autenticado.
- [Terraform](https://www.terraform.io/downloads.html) instalado.

## Uso

```hcl
module "key_vault" {
    source              = "../module"
    resource_group_name = "meu-rg"
    location            = "brazilsouth"
    key_vault_name      = "meukeyvault123"
}

output "key_vault_id" {
    value = module.key_vault.key_vault_id
}

output "key_vault_uri" {
    value = module.key_vault.key_vault_uri
}
```

## Variáveis

| Nome                  | Descrição                        | Obrigatório | Padrão |
|-----------------------|----------------------------------|-------------|--------|
| `name`                | Nome do Key Vault                | Sim         | -      |
| `location`            | Região do recurso                | Sim         | -      |
| `resource_group_name` | Nome do Resource Group           | Sim         | -      |

## Saídas

- `vault_uri`: URI do Key Vault criado.
- `vault_id`: ID do recurso Key Vault.

## Set subscription_id on Linux
```bash
 export TF_VAR_subscription_id=$(az account list --query "[?name=='TBX-Sandbox'].id" --output tsv)
 ```

## Licença

MIT

## Contribuição

Contribuições são bem-vindas! Abra uma issue ou pull