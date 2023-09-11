provider "azurerm" {
  features {}
}

module "resource_group" {
  source      = "git::git@github.com:opz0/terraform-azure-resource-group.git?ref=master"
  name        = "app"
  environment = "test"
  location    = "North Europe"
}

module "vnet" {
  source              = "git::git@github.com:opz0/terraform-azure-vnet.git?ref=master"
  name                = "app"
  environment         = "test"
  resource_group_name = module.resource_group.resource_group_name
  location            = module.resource_group.resource_group_location
  address_space       = "10.0.0.0/16"
}
module "subnet" {
  source = "git::git@github.com:opz0/terraform-azure-subnet.git?ref=master"

  name                 = "app"
  environment          = "test"
  resource_group_name  = module.resource_group.resource_group_name
  location             = module.resource_group.resource_group_location
  virtual_network_name = module.vnet.vnet_name[0]

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
  depends_on = [module.resource_group, module.vnet]
  source     = "./../.."

  name        = "annkkdsovvddcc"
  environment = "test"
  label_order = ["name", "environment", ]

  resource_group_name = module.resource_group.resource_group_name

  purge_protection_enabled    = false
  enabled_for_disk_encryption = true

  sku_name = "standard"

  subnet_id          = module.subnet.default_subnet_id
  virtual_network_id = module.vnet.vnet_id[0]
  #private endpoint
  enable_private_endpoint = true

  #access_policy
  access_policy = [
    {
      object_id = "c0fdxxxxxxxxxxxxxxxx10aedf"
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
