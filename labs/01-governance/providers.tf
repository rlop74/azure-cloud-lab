# https://learn.microsoft.com/en-us/azure/developer/terraform/create-resource-group?tabs=azure-cli

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    # random = {
    #   source  = "hashicorp/terraform"
    #   version = "~>3.0"
    # }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {
  tenant_id = var.tenant_id
}
