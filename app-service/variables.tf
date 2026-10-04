variable "location" {
  description = "Azure region for the app service."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group that will hold the app service and plan."
  type        = string
}

variable "tags" {
  description = "Tags applied to the app service and plan."
  type        = map(string)
  default     = {}
}

# Single object carrying the App Service configuration. Each environment
# supplies this object from its terraform.tfvars. Deploys a Node.js code stack
# by default, or a container image when the `container` variable is set.
variable "app_service" {
  description = "App Service (Linux) configuration. Node.js code stack by default; container image when var.container is set."
  type = object({
    app_name                          = string # globally unique web app name
    service_plan_name                 = string # name of the App Service Plan
    sku_name                          = string # e.g. B1, P1v3
    node_version                      = optional(string, "20-lts")
    always_on                         = optional(bool, true)
    https_only                        = optional(bool, true)
    ftps_state                        = optional(string, "Disabled")
    health_check_path                 = optional(string, "/")
    health_check_eviction_time_in_min = optional(number, 10)
    app_command_line                  = optional(string, "")
    http2_enabled                     = optional(bool, true)
    minimum_tls_version               = optional(string, "1.2")
    app_settings                      = optional(map(string), {}) # non-secret settings only
  })
}

variable "service_plan_id" {
  description = "Existing App Service Plan ID. When null, this module creates the plan."
  type        = string
  default     = null
}

variable "create_service_plan" {
  description = "Create an App Service Plan. Set false when service_plan_id is supplied by another module instance."
  type        = bool
  default     = true
}

variable "auth_settings" {
  description = "Optional Microsoft Entra App Service Authentication configuration."
  type = object({
    client_id                  = string
    tenant_id                  = string
    client_secret_setting_name = optional(string)
    allowed_audiences          = optional(list(string), [])
    unauthenticated_action     = optional(string, "Return401")
    excluded_paths             = optional(list(string), ["/health"])
  })
  default = null
}

variable "cors" {
  description = "Optional CORS configuration."
  type = object({
    allowed_origins     = list(string)
    support_credentials = optional(bool, true)
  })
  default = null
}

# When set, the web app runs this container image (pulled from ACR via the
# system-assigned managed identity) instead of the Node.js code stack. Passed
# as its own variable so environments can supply a registry URL derived from a
# registry module output. Leave null (default) for a code deployment.
variable "container" {
  description = "Optional container image configuration. Null for a Node.js code deployment."
  type = object({
    image_name   = string                     # repository/image name in the registry
    image_tag    = optional(string, "latest") # image tag to run
    registry_url = string                     # e.g. https://myacr.azurecr.io
  })
  default = null
}

# Optional subnet for regional VNet integration. Must be delegated to
# Microsoft.Web/serverFarms and dedicated to this app's plan. Null (default)
# leaves the app without VNet integration.
variable "integration_subnet_id" {
  description = "Subnet ID (delegated to Microsoft.Web/serverFarms) for regional VNet integration, or null."
  type        = string
  default     = null
}

# Secret app settings are passed separately (marked sensitive) and merged into
# app_settings inside the module, keeping secrets out of terraform.tfvars.
variable "extra_app_settings" {
  description = "Additional (sensitive) app settings merged into app_settings."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "public_network_access_enabled" {
  description = "Should public network access be enabled for the App Service?"
  type        = bool
  default     = true
}
