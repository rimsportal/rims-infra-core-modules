data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                      = var.key_vault_name
  location                  = var.location
  resource_group_name       = var.resource_group_name
  tenant_id                 = var.tenant_id
  sku_name                  = var.sku_name
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled  = var.purge_protection_enabled
  enable_rbac_authorization = var.enable_rbac_authorization
  tags                      = var.tags
}

# Grant Key Vault Secrets Officer to the deployer identity (Terraform execution context)
resource "azurerm_role_assignment" "deployer_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.deployer_secrets_officer]
}

resource "azurerm_role_assignment" "secrets_user" {
  for_each             = toset(var.reader_principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}
