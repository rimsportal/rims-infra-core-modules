locals {
  # Container deployment is selected when a container image is supplied via the
  # dedicated `container` variable; otherwise the module deploys the Node.js
  # code stack, preserving the original (v0.1.0) behaviour.
  is_container = var.container != null
}

resource "azurerm_service_plan" "this" {
  count               = var.create_service_plan ? 1 : 0
  name                = var.app_service.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service.sku_name
  tags                = var.tags
}

resource "azurerm_linux_web_app" "this" {
  name                          = var.app_service.app_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = var.create_service_plan ? azurerm_service_plan.this[0].id : var.service_plan_id
  https_only                    = var.app_service.https_only
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  # Optional regional VNet integration. When an integration subnet (delegated to
  # Microsoft.Web/serverFarms) is supplied, the app's outbound traffic routes
  # into the VNet so it can reach private endpoints / injected backends.
  virtual_network_subnet_id = var.integration_subnet_id

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
    http2_enabled                           = var.app_service.http2_enabled
    minimum_tls_version                     = var.app_service.minimum_tls_version
    health_check_path                       = var.app_service.health_check_path
    app_command_line                        = var.app_service.app_command_line
    container_registry_use_managed_identity = local.is_container ? true : null

    # Route all outbound traffic through the VNet when integration is enabled.
    vnet_route_all_enabled = var.integration_subnet_id == null ? null : true

    application_stack {
      # Node.js (code) deployment — used when no container image is supplied.
      node_version = local.is_container ? null : var.app_service.node_version

      # Container (Docker) deployment — used when var.container is set.
      docker_image_name   = local.is_container ? "${var.container.image_name}:${var.container.image_tag}" : null
      docker_registry_url = local.is_container ? var.container.registry_url : null
    }

    dynamic "cors" {
      for_each = var.cors == null ? [] : [var.cors]
      content {
        allowed_origins     = cors.value.allowed_origins
        support_credentials = cors.value.support_credentials
      }
    }
  }

  dynamic "auth_settings_v2" {
    for_each = var.auth_settings == null ? [] : [var.auth_settings]
    content {
      auth_enabled           = true
      require_authentication = true
      unauthenticated_action = auth_settings_v2.value.unauthenticated_action
      default_provider       = "azureactivedirectory"
      excluded_paths         = auth_settings_v2.value.excluded_paths

      active_directory_v2 {
        client_id                  = auth_settings_v2.value.client_id
        client_secret_setting_name = auth_settings_v2.value.client_secret_setting_name
        tenant_auth_endpoint       = "https://login.microsoftonline.com/${auth_settings_v2.value.tenant_id}/v2.0"
        allowed_audiences          = auth_settings_v2.value.allowed_audiences
      }

      login { token_store_enabled = true }
    }
  }

  # Non-secret settings from the object, merged with sensitive settings.
  app_settings = merge(var.app_service.app_settings, var.extra_app_settings)
}
