provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "cypik/resource-group/azure"
  version     = "1.0.2"
  name        = "app"
  environment = "test"
  location    = "East US"
}

data "azurerm_client_config" "this" {}

module "log-analytics" {
  source                           = "git::git@github.com:cypik/terraform-azure-log-analytics.git?ref=update/suresh"
  name                             = "app"
  environment                      = "test"
  resource_group_name              = module.resource_group.resource_group_name
  log_analytics_workspace_location = module.resource_group.resource_group_location
}

module "keyvault" {
  source              = "../../"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.this.tenant_id
  diagnostic_settings = [
    {
      name                  = "test"
      workspace_resource_id = module.log-analytics.workspace_id
    }
  ]
}