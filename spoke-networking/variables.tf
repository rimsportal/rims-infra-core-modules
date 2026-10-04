variable "vnet_name" {
  description = "Name of the spoke virtual network"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to deploy spoke resources into"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the spoke VNet — from IP plan"
  type        = list(string)
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "Map of subnet name to configuration."
  type = map(object({
    cidr = string
    # Optional service delegation. service_name e.g. "Microsoft.Web/serverFarms".
    delegation = optional(object({
      service_name = string
      actions      = optional(list(string))
    }))
    # Set false on subnets that host private endpoints.
    private_endpoint_network_policies_enabled = optional(bool, true)
    service_endpoints                         = optional(list(string), [])
  }))
}

variable "hub_vnet_id" {
  description = "Optional resource ID of a hub VNet. Leave null for a standalone spoke."
  type        = string
  default     = null
}

variable "hub_vnet_name" {
  description = "Optional name of the hub VNet."
  type        = string
  default     = null
}

variable "hub_resource_group_name" {
  description = "Optional resource group of the hub VNet."
  type        = string
  default     = null
}
