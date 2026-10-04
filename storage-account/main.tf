resource "azurerm_storage_account" "this" {
  name                            = var.storage.account_name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.storage.account_tier
  account_replication_type        = var.storage.replication_type
  min_tls_version                 = var.storage.min_tls_version
  https_traffic_only_enabled      = true
  public_network_access_enabled   = var.storage.public_network_access_enabled
  shared_access_key_enabled       = var.storage.shared_access_key_enabled
  allow_nested_items_to_be_public = false
  tags                            = var.tags

  dynamic "blob_properties" {
    for_each = var.storage.versioning_enabled || var.storage.delete_retention_days > 0 || var.storage.container_delete_retention_days > 0 ? [1] : []
    content {
      versioning_enabled = var.storage.versioning_enabled
      dynamic "delete_retention_policy" {
        for_each = var.storage.delete_retention_days > 0 ? [1] : []
        content { days = var.storage.delete_retention_days }
      }
      dynamic "container_delete_retention_policy" {
        for_each = var.storage.container_delete_retention_days > 0 ? [1] : []
        content { days = var.storage.container_delete_retention_days }
      }
    }
  }
}

resource "azurerm_storage_container" "this" {
  for_each              = toset(var.storage.containers)
  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
