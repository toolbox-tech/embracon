terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.38.1"
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  # Para ver a subscrição rode o comando az account list --query "[?name=='Nome da Assinatura'].id" --output tsv
  features {}
}