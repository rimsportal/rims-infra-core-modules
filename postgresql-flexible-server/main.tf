resource "azurerm_postgresql_flexible_server" "this" {
  name                          = var.postgres.server_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = var.postgres.postgres_version
  administrator_login           = var.postgres.administrator_login
  administrator_password        = var.administrator_password
  sku_name                      = var.postgres.sku_name
  storage_mb                    = var.postgres.storage_mb
  zone                          = var.postgres.zone
  public_network_access_enabled = var.postgres.public_network_access_enabled
  backup_retention_days         = var.postgres.backup_retention_days
  geo_redundant_backup_enabled  = var.postgres.geo_redundant_backup_enabled
  tags                          = var.tags

  dynamic "high_availability" {
    for_each = var.postgres.high_availability_enabled ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.postgres.standby_availability_zone
    }
  }
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = var.postgres.database_name
  server_id = azurerm_postgresql_flexible_server.this.id
  charset   = "UTF8"
  collation = "en_US.utf8"

  depends_on = [azurerm_postgresql_flexible_server_configuration.secure_transport]
}

# Allow other Azure services (e.g. the App Service) to reach the server.
# The 0.0.0.0 start/end is the Azure convention for "allow Azure services".
resource "azurerm_postgresql_flexible_server_firewall_rule" "azure_services" {
  count            = var.postgres.public_network_access_enabled && var.postgres.allow_azure_services ? 1 : 0
  name             = "allow-azure-services"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

# Optional: allow a single client IP (e.g. your workstation) for db:init/seed.
resource "azurerm_postgresql_flexible_server_firewall_rule" "client_ip" {
  count            = var.postgres.public_network_access_enabled && var.postgres.client_ip != "" ? 1 : 0
  name             = "allow-client-ip"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = var.postgres.client_ip
  end_ip_address   = var.postgres.client_ip
}

resource "azurerm_postgresql_flexible_server_configuration" "secure_transport" {
  count     = var.postgres.require_secure_transport ? 1 : 0
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "on"

  depends_on = [azurerm_postgresql_flexible_server_configuration.minimum_tls]
}

resource "azurerm_postgresql_flexible_server_configuration" "minimum_tls" {
  count     = var.postgres.require_secure_transport ? 1 : 0
  name      = "ssl_min_protocol_version"
  server_id = azurerm_postgresql_flexible_server.this.id
  value     = "TLSv1.2"
}
