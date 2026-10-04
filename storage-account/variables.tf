variable "location" {
  description = "Azure region for the storage account."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will hold the storage account."
  type        = string
}

variable "tags" {
  description = "Tags applied to the storage account."
  type        = map(string)
  default     = {}
}

# Storage configuration supplied as one object from terraform.tfvars.
variable "storage" {
  description = "Storage account configuration."
  type = object({
    account_name                    = string # globally unique, 3-24 lowercase alphanumeric
    account_tier                    = optional(string, "Standard")
    replication_type                = optional(string, "LRS") # LRS, GRS, ...
    min_tls_version                 = optional(string, "TLS1_2")
    containers                      = optional(list(string), ["inspection-images", "generated-pdfs"])
    public_network_access_enabled   = optional(bool, true)
    shared_access_key_enabled       = optional(bool, true)
    versioning_enabled              = optional(bool, false)
    delete_retention_days           = optional(number, 0)
    container_delete_retention_days = optional(number, 0)
  })
}
