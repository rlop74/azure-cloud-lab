resource "azurerm_resource_group" "demoStorage" {
  name     = "demoStorage"
  location = var.resource_group_location

  tags = {
    owner       = "cloud-admin"
    application = "cloudlab"
    environment = "lab"
  }
}

resource "azurerm_storage_account" "dudongstorage" {
  name                       = "dudongstorage"
  resource_group_name        = azurerm_resource_group.demoStorage.name
  location                   = azurerm_resource_group.demoStorage.location
  account_tier               = "Standard"
  account_replication_type   = "LRS"
  account_kind               = "StorageV2"
  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  # updates after seeing terraform plan
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  local_user_enabled              = false


  blob_properties {

    # enables soft delete for individual blobs and defines retention period
    delete_retention_policy {
      days = 7
    }

    # enables soft delete for entire containers and defines retention period
    container_delete_retention_policy {
      days = 7
    }

    # enables blob versioning
    versioning_enabled = true
  }
}

resource "azurerm_storage_management_policy" "default_policy" {
  storage_account_id = azurerm_storage_account.dudongstorage.id

  rule {
    name    = "rule1"
    enabled = true
    filters {
      prefix_match = ["test/logs/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 30
        tier_to_archive_after_days_since_modification_greater_than = 90
        delete_after_days_since_modification_greater_than          = 365
      }
      snapshot {
        change_tier_to_archive_after_days_since_creation = 30
        delete_after_days_since_creation_greater_than    = 90
      }
      version {
        delete_after_days_since_creation = 90
      }
    }
  }
}

resource "azurerm_storage_container" "test" {
  name                  = "test"
  storage_account_id    = azurerm_storage_account.dudongstorage.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "container_iam" {
  scope = azurerm_storage_container.test.id

  role_definition_name = "Storage Blob Data Reader"

  # object id of user rlopez
  principal_id = var.rlopez_object_id
}
