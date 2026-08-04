locals {
  # Container deployment is selected when a container image is supplied via the
  # dedicated `container` variable; otherwise the module deploys the Node.js
  # code stack, preserving the original (v0.1.0) behaviour.
  is_container = var.container != null
}

resource "azurerm_service_plan" "this" {
  name                = var.app_service.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                = var.app_service.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = var.app_service.https_only
  tags                = var.tags

  # A system-assigned managed identity is always created so container
  # deployments can pull from Azure Container Registry via an AcrPull role
  # assignment (no registry admin credentials stored anywhere). It is harmless
  # for code (Node.js) deployments.
  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                               = var.app_service.always_on
    ftps_state                              = var.app_service.ftps_state
    health_check_path                       = var.app_service.health_check_path
    app_command_line                        = var.app_service.app_command_line
    container_registry_use_managed_identity = local.is_container ? true : null

    application_stack {
      # Node.js (code) deployment — used when no container image is supplied.
      node_version = local.is_container ? null : var.app_service.node_version

      # Container (Docker) deployment — used when var.container is set.
      docker_image_name   = local.is_container ? "${var.container.image_name}:${var.container.image_tag}" : null
      docker_registry_url = local.is_container ? var.container.registry_url : null
    }
  }

  # Non-secret settings from the object, merged with sensitive settings.
  app_settings = merge(var.app_service.app_settings, var.extra_app_settings)
}
