output "keys" {
  description = "A map of key names with full key details."
  value       = module.keys
}

output "keys_resource_ids" {
  description = "Key names mapped to their IDs and versionless IDs."
  value = {
    for kk, kv in module.keys : kk => {
      resource_id             = kv.resource_id
      resource_versionless_id = kv.resource_versionless_id
      id                      = kv.id
      versionless_id          = kv.versionless_id
    }
  }
}

output "name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.this.name
}

output "private_endpoints" {
  description = "Private endpoints linked to the Key Vault."
  value       = var.private_endpoints_manage_dns_zone_group ? azurerm_private_endpoint.this : azurerm_private_endpoint.this_unmanaged_dns_zone_groups
}

output "resource_id" {
  description = "The resource ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "secrets_resource_ids" {
  description = "Secret names mapped to their resource IDs."
  value = {
    for sk, sv in module.secrets : sk => sv
  }
}

output "uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "secrets" {
  description = "A map of secret names with full secret details."
  value       = module.secrets
}