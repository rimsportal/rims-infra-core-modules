output "vnet_id" {
  description = "Resource ID of the spoke virtual network."
  value       = azurerm_virtual_network.spoke.id
}

output "vnet_name" {
  description = "Name of the spoke virtual network."
  value       = azurerm_virtual_network.spoke.name
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID."
  value       = { for k, s in azurerm_subnet.subnets : k => s.id }
}
