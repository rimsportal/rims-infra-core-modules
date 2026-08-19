resource "azurerm_private_dns_zone" "this" {
  for_each            = toset(var.zone_names)
  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Optional VNet links (e.g. link every zone to the hub VNet). Spokes typically
# create their own links to these zones from their own stack.
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = {
    for pair in setproduct(var.zone_names, keys(var.vnet_links)) :
    "${pair[0]}|${pair[1]}" => {
      zone      = pair[0]
      link_name = pair[1]
      vnet_id   = var.vnet_links[pair[1]]
    }
  }

  name                  = each.value.link_name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value.zone].name
  virtual_network_id    = each.value.vnet_id
  registration_enabled  = false
  tags                  = var.tags
}
