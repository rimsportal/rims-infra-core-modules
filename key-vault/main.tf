data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  soft_delete_retention_days    = var.soft_delete_retention_days
  purge_protection_enabled      = var.purge_protection_enabled
  rbac_authorization_enabled    = var.enable_rbac_authorization
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}

# -----------------------------------------------------------------------------
# Access Policy Mode (default: enable_rbac_authorization = false)
# Compatible with Contributor role (does NOT require User Access Admin permissions)
# -----------------------------------------------------------------------------
resource "azurerm_key_vault_access_policy" "deployer" {
  count        = var.enable_rbac_authorization ? 0 : 1
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = ["Get", "List", "Set", "Delete", "Purge", "Recover"]
}

resource "azurerm_key_vault_access_policy" "readers" {
  for_each     = var.enable_rbac_authorization ? [] : toset(var.reader_principal_ids)
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = each.value

  secret_permissions = ["Get", "List"]
}

# -----------------------------------------------------------------------------
# RBAC Mode (optional: enable_rbac_authorization = true)
# Requires User Access Admin / Owner role to write role assignments
# -----------------------------------------------------------------------------
resource "azurerm_role_assignment" "deployer_secrets_officer" {
  count                = var.enable_rbac_authorization ? 1 : 0
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_role_assignment" "secrets_user" {
  for_each             = var.enable_rbac_authorization ? toset(var.reader_principal_ids) : []
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

# -----------------------------------------------------------------------------
# Key Vault Secrets
# -----------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_key_vault_access_policy.deployer,
    azurerm_role_assignment.deployer_secrets_officer
  ]
}
