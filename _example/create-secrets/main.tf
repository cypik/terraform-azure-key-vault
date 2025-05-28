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

data "http" "ip" {
  url = "https://api.ipify.org/"
  retry {
    attempts     = 5
    max_delay_ms = 1000
    min_delay_ms = 500
  }
}

data "azurerm_client_config" "current" {}

module "key_vault" {
  source              = "../../"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  network_acls = {
    bypass   = "AzureServices"
    ip_rules = ["${data.http.ip.response_body}/32"]
  }
  public_network_access_enabled = true
  role_assignments = {
    deployment_user_kv_admin = {
      role_definition_id_or_name = "Key Vault Administrator"
      principal_id               = data.azurerm_client_config.current.object_id
    }

  }
  secrets = [
    {
      name  = "db-password"
      value = "super-secret-password"
    }
  ]
  wait_for_rbac_before_secret_operations = {
    create = "60s"
  }
}