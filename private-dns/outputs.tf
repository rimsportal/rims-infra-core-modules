output "zone_ids" {
  description = "Map of zone name to zone resource ID."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}

output "zone_names" {
  description = "Map of zone name to zone name (identity map, convenient for consumers)."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.name }
}
