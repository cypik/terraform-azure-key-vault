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

module "keyvault" {
  source              = "../../"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.this.tenant_id
  legacy_access_policies = {
    test = {
      object_id               = data.azurerm_client_config.this.object_id
      certificate_permissions = ["Get", "List"]
    }
  }
  legacy_access_policies_enabled = true
}