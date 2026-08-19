variable "resource_group_name" {
  description = "Resource group that will hold the private DNS zones."
  type        = string
}

variable "zone_names" {
  description = "List of private DNS zone names to create (e.g. privatelink.vaultcore.azure.net)."
  type        = list(string)
}

variable "vnet_links" {
  description = "Map of link name -> VNet ID. Each VNet is linked to every zone."
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags applied to the zones and links."
  type        = map(string)
  default     = {}
}
