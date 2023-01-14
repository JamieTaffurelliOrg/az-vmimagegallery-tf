variable "resource_group_name" {
  type        = string
  description = "Name of the Resource Group to deploy to"
}

variable "location" {
  type        = string
  description = "Location to deploy resources"
}
variable "image_gallery_name" {
  type        = string
  description = "Name of Shared Image Gallery"
}

variable "image_gallery_description" {
  type        = string
  description = "Description of Shared Image Gallery"
}

variable "images" {
  type = list(object({
    name                                = string
    os_type                             = string
    description                         = string
    disk_types_not_allowed              = optional(list(string), ["Standard_LRS"])
    end_of_life_date                    = optional(string)
    eula                                = optional(string)
    architecture                        = optional(string, "x64")
    hyper_v_generation                  = optional(string, "V1")
    max_recommended_vcpu_count          = optional(number)
    min_recommended_vcpu_count          = optional(number)
    max_recommended_memory_in_gb        = optional(number)
    min_recommended_memory_in_gb        = optional(number)
    privacy_statement_uri               = optional(string)
    release_note_uri                    = optional(string)
    trusted_launch_enabled              = optional(bool, false)
    accelerated_network_support_enabled = optional(bool, true)
    publisher                           = string
    offer                               = string
    sku                                 = string
  }))

  validation {
    condition = alltrue(
      [
        for image in var.images : contains(["Linux", "Windows"], image.os_type)
      ]
    )
    error_message = "OS type must be Windows or Linux."
  }
  description = "Images to deploy to Shared Image Gallery"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account to store vm config scripts"
}

variable "storage_account_network_rules" {
  type = object(
    {
      default_action             = optional(string, "Deny")
      ip_rules                   = optional(list(string), [])
      virtual_network_subnet_ids = optional(list(string), [])
    }
  )
  default     = {}
  description = "The Storage Account firewall rules"
}

variable "log_analytics_workspace" {
  type = object(
    {
      name                = string
      resource_group_name = string
    }
  )
  description = "The existing log analytics workspaces to send diagnostic logs to"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources"
}
