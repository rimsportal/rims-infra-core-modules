variable "location" {
  description = "Azure region for the container registry."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will hold the container registry."
  type        = string
}

variable "tags" {
  description = "Tags applied to the container registry."
  type        = map(string)
  default     = {}
}

# Single object carrying the Azure Container Registry configuration. Each
# environment supplies this object from its terraform.tfvars.
variable "registry" {
  description = "Azure Container Registry configuration."
  type = object({
    name          = string                    # globally unique, 5-50 alphanumeric
    sku           = optional(string, "Basic") # Basic, Standard, Premium
    admin_enabled = optional(bool, false)      # keep false; pull via managed identity
  })
}
