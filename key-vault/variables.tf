variable "key_vault_name" {
  description = "Globally unique name for the Azure Key Vault (3-24 alphanumeric characters and hyphens)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group where Key Vault is deployed"
  type        = string
}

variable "location" {
  description = "Azure region location"
  type        = string
}

variable "tenant_id" {
  description = "Azure Active Directory tenant ID"
  type        = string
}

variable "sku_name" {
  description = "SKU for the Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention period in days (7 to 90)"
  type        = number
  default     = 7
}

variable "purge_protection_enabled" {
  description = "Enable purge protection to prevent permanent deletion during soft delete period"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "Use Azure RBAC for authorization instead of access policies"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether the Key Vault public endpoint is enabled."
  type        = bool
  default     = true
}

variable "secrets" {
  description = "Map of secret names to secret values to store in Key Vault"
  type        = map(string)
  default     = {}
}

variable "reader_principal_ids" {
  description = "List of Principal IDs (e.g. App Service Managed Identity) to grant Key Vault Secrets User role"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}
