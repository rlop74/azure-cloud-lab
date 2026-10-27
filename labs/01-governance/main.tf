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

# AZURE SUBSCRIPTION 
data "azurerm_subscription" "current" {

}

# RESOURCE GROUPS ===============================================

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

# RBAC ASSIGNMENTS ===============================================

# declare Microsoft Entra ID groups
data "azuread_group" "cloud_admins" {
  display_name     = "Cloud-Admin"
  security_enabled = true
}

data "azuread_group" "cloud_engineers" {
  display_name     = "Cloud-Engineers"
  security_enabled = true
}

data "azuread_group" "developers" {
  display_name     = "Developers"
  security_enabled = true
}

data "azuread_group" "auditors" {
  display_name     = "Auditors"
  security_enabled = true
}

# Reference a target Resource Group scope (might not be needed since we already declared RGs)
# data "azurerm_resource_group" "dev" {
#   name = "rg-cloudlab-dev"
# }

# Create RBAC role assignment for prod environment
resource "azurerm_role_assignment" "prod_rbac_cloud_admins" {
  scope                = azurerm_resource_group.prod.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_group.cloud_admins.object_id
}

resource "azurerm_role_assignment" "prod_rbac_cloud_engineers" {
  scope                = azurerm_resource_group.prod.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.cloud_engineers.object_id
}

resource "azurerm_role_assignment" "prod_rbac_auditors" {
  scope                = azurerm_resource_group.prod.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.auditors.object_id
}

# create RBAC role assignment for dev environment 
resource "azurerm_role_assignment" "dev_rbac_cloud_admins" {
  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Owner"
  principal_id         = data.azuread_group.cloud_admins.object_id
}

resource "azurerm_role_assignment" "dev_rbac_cloud_engineers" {
  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.cloud_engineers.object_id
}

resource "azurerm_role_assignment" "dev_rbac_developers" {
  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_group.developers.object_id
}

resource "azurerm_role_assignment" "dev_rbac_auditors" {
  scope                = azurerm_resource_group.dev.id
  role_definition_name = "Reader"
  principal_id         = data.azuread_group.auditors.object_id
}

# AZURE POLICY RESOURCE LOCK ===============================================

# resource lock
resource "azurerm_management_lock" "accidental_delete_lock" {
  name       = "AccidentalDeleteLock"
  scope      = azurerm_resource_group.prod.id
  lock_level = "CanNotDelete"
  notes      = "this Resource Group is locked to prevent accidental deletion"
}

# custom policy (region)
resource "azurerm_policy_definition" "region_policy" {
  name        = "east-region-lock"
  policy_type = "Custom"
  mode        = "All"
  # mode         = "Indexed"
  # https://learn.microsoft.com/en-us/azure/governance/policy/concepts/definition-structure-basics
  display_name = "Allowed locations policy"

  policy_rule = jsonencode({
    if = {
      field = "location"
      notIn = ["eastus", "eastus2", "global"]
    }
    then = {
      effect = "deny"
    }
  })
}

resource "azurerm_subscription_policy_assignment" "subscription_region_lock" {
  name                 = "subscription-region-lock"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.region_policy.id
}
