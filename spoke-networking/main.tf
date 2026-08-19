resource "azurerm_virtual_network" "spoke" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  location            = var.location
  tags                = var.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [each.value.cidr]

  # Disable for subnets that host private endpoints (default stays enabled).
  private_endpoint_network_policies_enabled = each.value.private_endpoint_network_policies_enabled

  service_endpoints = each.value.service_endpoints

  # Optional service delegation (e.g. Microsoft.Web/serverFarms for App Service
  # VNet integration, or Microsoft.DBforPostgreSQL/flexibleServers for Postgres
  # VNet injection). Actions default to the provider-computed set when omitted.
  dynamic "delegation" {
    for_each = each.value.delegation == null ? [] : [each.value.delegation]
    content {
      name = "delegation"
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

# Spoke -> Hub peering.
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                         = "${var.vnet_name}-to-hub"
  resource_group_name          = var.resource_group_name
  virtual_network_name         = azurerm_virtual_network.spoke.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Hub -> Spoke peering (created on the hub side; requires access to the hub RG).
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                         = "hub-to-${var.vnet_name}"
  resource_group_name          = var.hub_resource_group_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
