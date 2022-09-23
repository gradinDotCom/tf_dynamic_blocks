#---------------------------------------------
#  TERRAFORM SETUP
#---------------------------------------------

terraform {
  required_version = "~> 1.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-rg"
  location = "West Europe"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_queue" "example" {
  name                 = "examplestoragequeue"
  storage_account_name = azurerm_storage_account.example.name
}

resource "azurerm_eventgrid_system_topic" "example" {
  name                   = "example-system-topic"
  location               = "Global"
  resource_group_name    = azurerm_resource_group.example.name
  source_arm_resource_id = azurerm_resource_group.example.id
  topic_type             = "Microsoft.Resources.ResourceGroups"
}

variable "filters" {}
variable "adv_block" {}

resource "azurerm_eventgrid_system_topic_event_subscription" "example" {
  name                = "example-event-subscription"
  system_topic        = azurerm_eventgrid_system_topic.example.name
  resource_group_name = azurerm_resource_group.example.name

  storage_queue_endpoint {
    storage_account_id = azurerm_storage_account.example.id
    queue_name         = azurerm_storage_queue.example.name
  }

  dynamic "advanced_filter" {
    for_each = var.adv_block
    content {
        dynamic "string_in" {
            for_each = lookup(var.filters, "string_in", {})
            iterator = filter
            content {
                key = filter.key
                values = filter.value
            }
        }
        dynamic "string_begins_with" {
            for_each = lookup(var.filters, "string_begins_with", {})
            iterator = filter
            content {
                key = filter.key
                values = filter.value
            }
        }
    }
  }
}