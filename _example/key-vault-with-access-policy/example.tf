provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "cypik/resource-group/azure"
  version     = "1.0.2"
  name        = "app"
  environment = "test"
  location    = "North Europe"
}

module "vnet" {
  source                 = "cypik/vnet/azure"
  version                = "1.0.2"
  name                   = "app"
  environment            = "test"
  resource_group_name    = module.resource_group.resource_group_name
  location               = module.resource_group.resource_group_location
  address_space          = "10.0.0.0/16"
  enable_ddos_pp         = false
  enable_network_watcher = false
}


module "subnet" {
  source               = "cypik/subnet/azure"
  version              = "1.0.2"
  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = join("", module.vnet[*].name)

  #subnet
  subnet_names    = ["subnet1"]
  subnet_prefixes = ["10.0.1.0/24"]

  # route_table
  enable_route_table = true
  route_table_name   = "default_subnet"
  routes = [
    {
      name           = "rt-test"
      address_prefix = "0.0.0.0/0"
      next_hop_type  = "Internet"
    }
  ]
}

#Key Vault
module "vault" {
  source                      = "./../.."
  name                        = "ann149867hdc"
  environment                 = "test"
  resource_group_name         = module.resource_group.resource_group_name
  purge_protection_enabled    = false
  enabled_for_disk_encryption = true
  sku_name                    = "standard"
  subnet_id                   = module.subnet.default_subnet_id
  virtual_network_id          = module.vnet.id
  enable_private_endpoint     = true

  depends_on = [module.resource_group, module.vnet]
  access_policy = [
    {
      object_id = "d5ae204c-2aa4-41a4-8fbe-240bcc0c1710"
      key_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "UnwrapKey",
        "WrapKey",
        "GetRotationPolicy"
      ]
      certificate_permissions = [
        "Get",
        "List",
        "Update",
        "Create",
        "Import",
        "Delete",
        "Recover",
        "Backup",
        "Restore",
        "ManageContacts",
        "ManageIssuers",
        "GetIssuers",
        "ListIssuers",
        "SetIssuers",
        "DeleteIssuers"
      ]
      secret_permissions = [
        "Get",
        "List",
        "Set",
        "Delete",
        "Recover",
        "Backup",
        "Restore"
      ]
      storage_permissions = []
    },
  ]

}
