output "key_vault_id" {
  description = "Resource ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to their full secret IDs (including version)"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.id }
}

output "secret_versionless_ids" {
  description = "Map of secret names to their versionless IDs (recommended for App Service Key Vault references)"
  value       = { for k, v in azurerm_key_vault_secret.secrets : k => v.versionless_id }
}
