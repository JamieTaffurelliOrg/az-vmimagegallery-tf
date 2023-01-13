resource "azurerm_shared_image_gallery" "images" {
  name                = var.image_gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = var.image_gallery_description
  tags                = var.tags
}

resource "azurerm_shared_image" "images" {
  for_each                            = { for k in var.images : k.name => k if k != null }
  name                                = each.key
  gallery_name                        = azurerm_shared_image_gallery.images.name
  resource_group_name                 = var.resource_group_name
  location                            = var.location
  os_type                             = each.value["os_type"]
  description                         = each.value["description"]
  disk_types_not_allowed              = each.value["disk_types_not_allowed"]
  end_of_life_date                    = each.value["end_of_life_date"]
  eula                                = each.value["eula"]
  architecture                        = each.value["architecture"]
  hyper_v_generation                  = each.value["hyper_v_generation"]
  max_recommended_vcpu_count          = each.value["max_recommended_vcpu_count"]
  min_recommended_vcpu_count          = each.value["min_recommended_vcpu_count"]
  max_recommended_memory_in_gb        = each.value["max_recommended_memory_in_gb"]
  min_recommended_memory_in_gb        = each.value["min_recommended_memory_in_gb"]
  privacy_statement_uri               = each.value["privacy_statement_uri"]
  release_note_uri                    = each.value["release_note_uri"]
  trusted_launch_enabled              = each.value["trusted_launch_enabled"]
  accelerated_network_support_enabled = each.value["accelerated_network_support_enabled"]
  specialized                         = false

  identifier {
    publisher = each.value["publisher"]
    offer     = each.value["offer"]
    sku       = each.value["sku"]
  }
  tags = var.tags
}

resource "azurerm_user_assigned_identity" "images" {
  name                = var.image_gallery_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}
