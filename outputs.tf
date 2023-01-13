output "shared_image_gallery_id" {
  value       = azurerm_shared_image_gallery.images.id
  description = "Resource ID of the Shared Image Gallery"
}

output "shared_image_gallery_unique_name" {
  value       = azurerm_shared_image_gallery.images.unique_name
  description = "The unique name of the Shared Image Gallery"
}

output "images" {
  value       = azurerm_shared_image.images
  description = "The images deployed to the Shared Image Gallery"
}

output "user_assigned_identity_id" {
  value       = azurerm_user_assigned_identity.images.id
  description = "The resource ID of the User Assigned Identity"
}

output "user_assigned_identity_principal_id" {
  value       = azurerm_user_assigned_identity.images.principal_id
  description = "Object ID of the User Assigned Identity"
}

output "user_assigned_identity_client_id" {
  value       = azurerm_user_assigned_identity.images.client_id
  description = "Client ID of the User Assigned Identity"
}

output "user_assigned_identity_tenant_id" {
  value       = azurerm_user_assigned_identity.images.tenant_id
  description = "Tenant ID of the User Assigned Identity"
}
