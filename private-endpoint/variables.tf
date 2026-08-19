variable "name" {
  description = "Name of the private endpoint."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the private endpoint."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID (with PE network policies disabled) hosting the private endpoint."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Resource ID of the target service (Key Vault, Storage account, etc.)."
  type        = string
}

variable "subresource_names" {
  description = "Target sub-resource(s), e.g. [\"vault\"] for Key Vault or [\"blob\"] for Storage."
  type        = list(string)
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to register the endpoint's A record in."
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to the private endpoint."
  type        = map(string)
  default     = {}
}
