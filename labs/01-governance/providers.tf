# https://learn.microsoft.com/en-us/azure/developer/terraform/create-resource-group?tabs=azure-cli

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
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
