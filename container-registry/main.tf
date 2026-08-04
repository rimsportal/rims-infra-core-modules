resource "azurerm_container_registry" "this" {
  name                = var.registry.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.registry.sku
  admin_enabled       = var.registry.admin_enabled
  tags                = var.tags
}
