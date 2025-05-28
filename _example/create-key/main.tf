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
  location            = module.resource_group.resource_group_location
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  keys = {
    cmk_for_storage_account = {
      key_opts = ["decrypt", "encrypt", "sign", "unwrapKey", "verify", "wrapKey"]
      key_type = "RSA"
      name     = "cmk-for-storage-account"
      key_size = 2048
    }
  }
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
  wait_for_rbac_before_key_operations = {
    create = "60s"
  }
}