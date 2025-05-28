variable "name" {
  type        = string
  description = "The name of the Key Vault."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.name))
    error_message = "The name must be between 3 and 24 characters long and can only contain letters, numbers and dashes."
  }
  validation {
    error_message = "The name must not contain two consecutive dashes"
    condition     = !can(regex("--", var.name))
  }
  validation {
    error_message = "The name must start with a letter"
    condition     = can(regex("^[a-zA-Z]", var.name))
  }
  validation {
    error_message = "The name must end with a letter or number"
    condition     = can(regex("[a-zA-Z0-9]$", var.name))
  }
}

variable "environment" {
  type        = string
  default     = ""
  description = "Environment (e.g. `prod`, `dev`, `staging`)."
}

variable "repository" {
  type        = string
  default     = "https://github.com/cypik/terraform-azure-key-vault"
  description = "Terraform current module repo"
}

variable "label_order" {
  type        = list(any)
  default     = ["name", "environment", ]
  description = "Label order, e.g. sequence of application name and environment `name`,`environment`,'attribute' [`webserver`,`qa`,`devops`,`public`,] ."
}

variable "managedby" {
  type        = string
  default     = "info@cypik.com"
  description = "ManagedBy, eg 'info@cypik.com'"
}

variable "extra_tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. map(`BusinessUnit`,`XYZ`)."
}

variable "location" {
  type        = string
  description = "The Azure location where the resources will be deployed."
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
}

variable "tenant_id" {
  type        = string
  description = "The Azure tenant ID used for authenticating requests to Key Vault. You can use the `azurerm_client_config` data source to retrieve it."

  validation {
    condition     = can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", var.tenant_id))
    error_message = "The tenant ID must be a valid GUID. Letters must be lowercase."
  }
}

variable "diagnostic_settings" {
  type = list(object({
    name                                     = optional(string, null)
    log_categories                           = optional(set(string), [])
    log_groups                               = optional(set(string), ["allLogs"])
    metric_categories                        = optional(set(string), ["AllMetrics"])
    log_analytics_destination_type           = optional(string, "Dedicated")
    workspace_resource_id                    = optional(string, null)
    storage_account_resource_id              = optional(string, null)
    event_hub_authorization_rule_resource_id = optional(string, null)
    event_hub_name                           = optional(string, null)
    marketplace_partner_resource_id          = optional(string, null)
  }))
  default     = []
  nullable    = false
  description = "List of diagnostic settings for Key Vault"

  validation {
    condition = alltrue([
      for v in var.diagnostic_settings :
      contains(["Dedicated", "AzureDiagnostics"], v.log_analytics_destination_type)
    ])
    error_message = "Log analytics destination type must be one of: 'Dedicated', 'AzureDiagnostics'."
  }

  validation {
    condition = alltrue([
      for v in var.diagnostic_settings :
      v.workspace_resource_id != null || v.storage_account_resource_id != null || v.event_hub_authorization_rule_resource_id != null || v.marketplace_partner_resource_id != null
    ])
    error_message = "At least one of `workspace_resource_id`, `storage_account_resource_id`, `marketplace_partner_resource_id`, or `event_hub_authorization_rule_resource_id` must be set."
  }
}


variable "enable_telemetry" {
  type        = bool
  default     = true
  description = "Controls whether telemetry is enabled for the module; see https://aka.ms/avm/telemetryinfo for details."
}

variable "enabled_for_deployment" {
  type        = bool
  default     = false
  description = "Specifies whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault."
}

variable "enabled_for_disk_encryption" {
  type        = bool
  default     = false
  description = "Specifies whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
}

variable "enabled_for_template_deployment" {
  type        = bool
  default     = false
  description = "Specifies whether Azure Resource Manager is permitted to retrieve secrets from the vault."
}

variable "keys" {
  type = map(object({
    name     = string
    key_type = string
    key_opts = optional(list(string), ["sign", "verify"])

    key_size        = optional(number, null)
    curve           = optional(string, null)
    not_before_date = optional(string, null)
    expiration_date = optional(string, null)
    tags            = optional(map(any), null)

    role_assignments = optional(map(object({
      role_definition_id_or_name             = string
      principal_id                           = string
      description                            = optional(string, null)
      skip_service_principal_aad_check       = optional(bool, false)
      condition                              = optional(string, null)
      condition_version                      = optional(string, null)
      delegated_managed_identity_resource_id = optional(string, null)
      principal_type                         = optional(string, null)
    })), {})

    rotation_policy = optional(object({
      automatic = optional(object({
        time_after_creation = optional(string, null)
        time_before_expiry  = optional(string, null)
      }), null)
      expire_after         = optional(string, null)
      notify_before_expiry = optional(string, null)
    }), null)
  }))
  default     = {}
  nullable    = false
  description = "Map of Key Vault keys to create, with rotation policies and optional role assignments; keyed arbitrarily to avoid unknown-plan-time issues."

}

variable "legacy_access_policies" {
  type = map(object({
    object_id               = string
    application_id          = optional(string, null)
    certificate_permissions = optional(set(string), [])
    key_permissions         = optional(set(string), [])
    secret_permissions      = optional(set(string), [])
    storage_permissions     = optional(set(string), [])
  }))
  default     = {}
  nullable    = false
  description = "Map of legacy access policies for Key Vault, keyed arbitrarily; requires `legacy_access_policies_enabled = true` and at least one permission set per entry."

  validation {
    error_message = "Object ID must be a valid GUID."
    condition     = alltrue([for _, v in var.legacy_access_policies : can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", v.object_id))])
  }
  validation {
    error_message = "Application ID must be null or a valid GUID."
    condition     = alltrue([for _, v in var.legacy_access_policies : v.application_id == null || can(regex("^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$", v.application_id))])
  }
  validation {
    error_message = "Certificate permissions must be a set composed of: `Backup`, `Create`, `Delete`, `DeleteIssuers`, `Get`, `GetIssuers`, `Import`, `List`, `ListIssuers`, `ManageContacts`, `ManageIssuers`, `Purge`, `Recover`, `Restore`, `SetIssuers`, and `Update`."
    condition     = alltrue([for _, v in var.legacy_access_policies : setintersection(["Backup", "Create", "Delete", "DeleteIssuers", "Get", "GetIssuers", "Import", "List", "ListIssuers", "ManageContacts", "ManageIssuers", "Purge", "Recover", "Restore", "SetIssuers", "Update"], v.certificate_permissions) == v.certificate_permissions])
  }
  validation {
    error_message = "Key permissions must be a set composed of: `Backup`, `Create`, `Decrypt`, `Delete`, `Encrypt`, `Get`, `Import`, `List`, `Purge`, `Recover`, `Restore`, `Sign`, `UnwrapKey`, `Update`, `Verify`, `WrapKey`, `Release`, `Rotate`, `GetRotationPolicy`, and `SetRotationPolicy`."
    condition     = alltrue([for _, v in var.legacy_access_policies : setintersection(["Backup", "Create", "Decrypt", "Delete", "Encrypt", "Get", "Import", "List", "Purge", "Recover", "Restore", "Sign", "UnwrapKey", "Update", "Verify", "WrapKey", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"], v.key_permissions) == v.key_permissions])
  }
  validation {
    error_message = "Secret permissions must be a set composed of: `Backup`, `Delete`, `Get`, `List`, `Purge`, `Recover`, `Restore`, and `Set`."
    condition     = alltrue([for _, v in var.legacy_access_policies : setintersection(["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"], v.secret_permissions) == v.secret_permissions])
  }
  validation {
    error_message = "Storage permissions must be a set composed of: `Backup`, `Delete`, `DeleteSAS`, `Get`, `GetSAS`, `List`, `ListSAS`, `Purge`, `Recover`, `RegenerateKey`, `Restore`, `Set`, `SetSAS`, and `Update`."
    condition     = alltrue([for _, v in var.legacy_access_policies : setintersection(["Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey", "Restore", "Set", "SetSAS", "Update"], v.storage_permissions) == v.storage_permissions])
  }
  validation {
    error_message = "At least one permission must be set."
    condition     = alltrue([for _, v in var.legacy_access_policies : length(v.certificate_permissions) + length(v.key_permissions) + length(v.secret_permissions) + length(v.storage_permissions) > 0])
  }
}

variable "legacy_access_policies_enabled" {
  type        = bool
  default     = false
  description = "Specifies whether legacy access policies are enabled for this Key Vault. Prevents use of Azure RBAC for data plane."
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = "The lock level to apply to the Key Vault. Default is `None`. Possible values are `None`, `CanNotDelete`, and `ReadOnly`."

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "network_acls" {
  type = object({
    bypass                     = optional(string, "None")
    default_action             = optional(string, "Deny")
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default     = {}
  description = "Configures Key Vault network ACLs with bypass, default action, IP rules, and subnet restrictions; set null to disable firewall."

  validation {
    condition     = var.network_acls == null ? true : contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "The bypass value must be either `AzureServices` or `None`."
  }
  validation {
    condition     = var.network_acls == null ? true : contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "The default_action value must be either `Allow` or `Deny`."
  }
}

variable "private_endpoints" {
  type = map(object({
    subnet_resource_id              = string
    location                        = optional(string)
    name                            = optional(string)
    resource_group_name             = optional(string)
    network_interface_name          = optional(string)
    private_service_connection_name = optional(string)
    private_dns_zone_group_name     = optional(string)
    private_dns_zone_resource_ids   = optional(list(string), [])
    ip_configurations = optional(list(object({
      name               = string
      private_ip_address = string
    })), [])
    application_security_group_associations = optional(map(string), {})
    tags                                    = optional(map(string), {})
  }))
  default     = {}
  nullable    = false
  description = "Map of Key Vault private endpoints with subnet, DNS, role assignments, ASGs, locks, IP configs, and optional names/tags."
}

variable "private_endpoints_manage_dns_zone_group" {
  type        = bool
  default     = true
  description = "Whether to manage private DNS zone groups with this module. If set to false, you must manage private DNS zone groups externally, e.g. using Azure Policy."
  nullable    = false
}

variable "purge_protection_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether protection against purge is enabled for this Key Vault. Note once enabled this cannot be disabled."
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
    principal_type                         = optional(string, null)
  }))
  default     = {}
  nullable    = false
  description = "Map of role assignments for Key Vault with fields like role_definition_id_or_name, principal_id, condition, and AAD check options (e.g., skip_service_principal_aad_check)."
}

variable "secrets" {
  description = "List of secrets to create"
  type = list(object({
    name             = string
    value            = string
    content_type     = optional(string)
    expiration_date  = optional(string)
    not_before_date  = optional(string)
    tags             = optional(map(string))
    role_assignments = optional(any)
  }))
  default = []
}

variable "sku_name" {
  type        = string
  default     = "standard"
  description = "The SKU name of the Key Vault. Default is `premium`. Possible values are `standard` and `premium`."

  validation {
    condition     = contains(["standard", "premium"], var.sku_name)
    error_message = "The SKU name must be either `standard` or `premium`."
  }
}

variable "soft_delete_retention_days" {
  type        = number
  default     = null
  description = <<DESCRIPTION
The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days.
DESCRIPTION

  validation {
    condition     = var.soft_delete_retention_days == null ? true : var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Value must be between 7 and 90."
  }
  validation {
    condition     = var.soft_delete_retention_days == null ? true : ceil(var.soft_delete_retention_days) == var.soft_delete_retention_days
    error_message = "Value must be an integer."
  }
}

variable "tags" {
  type        = map(string)
  default     = null
  description = "Map of tags to assign to the Key Vault resource."
}

variable "wait_for_rbac_before_contact_operations" {
  type = object({
    create  = optional(string, "30s")
    destroy = optional(string, "0s")
  })
  default     = {}
  description = "Time to wait (default: create=30s, destroy=0s) before contact operations when both role_assignments and contacts are set."
}

variable "wait_for_rbac_before_key_operations" {
  type = object({
    create  = optional(string, "30s")
    destroy = optional(string, "0s")
  })
  default     = {}
  description = "Time to wait (default: create=30s, destroy=0s) before key operations when both role_assignments and keys are set."
}

variable "wait_for_rbac_before_secret_operations" {
  type = object({
    create  = optional(string, "30s")
    destroy = optional(string, "0s")
  })
  default     = {}
  nullable    = false
  description = "Time to wait (default: create=30s, destroy=0s) before secret operations when both role_assignments and secrets are set."
}

variable "public_network_access_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Whether public network access is allowed for this Key Vault. Defaults to true"
}

variable "contacts" {
  type = map(object({
    email = string
    name  = optional(string, null)
    phone = optional(string, null)
  }))
  default     = {}
  description = "A map of contacts for the Key Vault. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time."
}