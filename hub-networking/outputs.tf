output "vnet_id" {
  description = "Resource ID of the hub virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the hub virtual network."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "Resource group holding the hub virtual network."
  value       = var.resource_group_name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID."
  value       = { for k, s in azurerm_subnet.subnets : k => s.id }
}
