variable "workspace_name" {
  description = "Log Analytics workspace name."
  type        = string
}

variable "application_insights_name" {
  description = "Workspace-based Application Insights component name."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "retention_days" {
  description = "Log retention in days."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Resource tags."
  type        = map(string)
  default     = {}
}
