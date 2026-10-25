# https://learn.microsoft.com/en-us/azure/developer/terraform/create-resource-group?tabs=azure-cli

# # Create a random name for the resource group using random_pet
# resource "random_pet" "rg_name" {
#   prefix = var.resource_group_name_prefix
# }
#
# # Create a resource group using the generated random name
# resource "azurerm_resource_group" "example" {
#   location = var.resource_group_location
#   name     = random_pet.rg_name.id
# }

resource "azurerm_resource_group" "dev" {
  location = var.resource_group_location
  name     = "rg-cloudlab-dev"

  tags = {
    environment = "development"
    owner       = "cloud-admin"
    application = "cloudlab"
  }
}

resource "azurerm_resource_group" "prod" {
  location = var.resource_group_location
  name     = "rg-cloudlab-prod"

  tags = {
    environment = "production"
    owner       = "cloud-admin"
    application = "cloudlab"
  }
}
