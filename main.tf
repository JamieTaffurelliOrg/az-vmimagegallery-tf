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

resource "azurerm_storage_account" "storage" {
  #checkov:skip=CKV2_AZURE_33:This is an old way of logging, diagnostics are enabled
  #checkov:skip=CKV_AZURE_33:This is an old way of logging, diagnostics are enabled
  #checkov:skip=CKV2_AZURE_18:This is unnecessary for most scenarios
  #checkov:skip=CKV2_AZURE_1:We may require some storage accounts to not have firewalls
  #checkov:skip=CKV_AZURE_59:Value is deprecated
  name                            = var.storage_account_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  account_kind                    = "StorageV2"
  account_tier                    = "Premium"
  account_replication_type        = "GRS"
  access_tier                     = "Hot"
  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true

  blob_properties {
    versioning_enabled            = true
    change_feed_enabled           = true
    change_feed_retention_in_days = 365
    last_access_time_enabled      = true

    delete_retention_policy {
      days = 365
    }

    container_delete_retention_policy {
      days = 365
    }
  }

  identity {
    type = "SystemAssigned"
  }
  tags = var.tags
}

resource "azurerm_storage_container" "container" {
  #checkov:skip=CKV2_AZURE_21:This is an old way of logging, diagnostics are enabled
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = "private"
}

resource "azurerm_storage_account_network_rules" "rules" {
  #checkov:skip=CKV_AZURE_35:We may require these storage accounts to be publicly accessible
  storage_account_id         = azurerm_storage_account.storage.id
  default_action             = var.storage_account_network_rules.default_action
  ip_rules                   = var.storage_account_network_rules.ip_rules
  virtual_network_subnet_ids = var.storage_account_network_rules.virtual_network_subnet_ids
  bypass                     = ["Logging", "Metrics", "AzureServices"]
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostics" {
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = azurerm_storage_account.storage.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  metric {
    category = "Transaction"

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_blob_diagnostics" {
  for_each                   = toset(["blobServices", "fileServices", "tableServices", "queueServices"])
  name                       = "${var.log_analytics_workspace.name}-security-logging"
  target_resource_id         = "${azurerm_storage_account.storage.id}/${each.key}/default/"
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.logs.id

  log {
    category = "StorageRead"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "StorageWrite"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  log {
    category = "StorageDelete"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Transaction"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 365
    }
  }

  metric {
    category = "Capacity"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}
