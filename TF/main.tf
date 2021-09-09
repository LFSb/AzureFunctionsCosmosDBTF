# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 0.14.9"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
  tags = {
     Environment = var.resource_group_environment,
     Owner = "Lee"
  }
}


resource "azurerm_cosmosdb_account" "acc" {
  name = "${var.cosmos_db_account_name}"
  location = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  offer_type = "Standard"
  kind = "GlobalDocumentDB"
  enable_automatic_failover = true
  consistency_policy {
    consistency_level = "Session"
  }
  geo_location {
    location = "${var.failover_location}"
    failover_priority = 1
  }
  geo_location {
    location = "${var.resource_group_location}"
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name = "${var.cosmos_db_name}"
  resource_group_name = "${azurerm_cosmosdb_account.acc.resource_group_name}"
  account_name = "${azurerm_cosmosdb_account.acc.name}"
}

resource "azurerm_cosmosdb_sql_container" "coll" {
  name = "${var.cosmos_db_container_name}"
  resource_group_name = "${azurerm_cosmosdb_account.acc.resource_group_name}"
  account_name = "${azurerm_cosmosdb_account.acc.name}"
  database_name = "${azurerm_cosmosdb_sql_database.db.name}"
  partition_key_path = "${var.cosmos_db_partition_key_path}"
}

output "cosmosdb_connectionstrings" {
   value = azurerm_cosmosdb_account.acc.connection_strings
   sensitive   = true
}


/*resource "azurerm_app_service_plan" "appserviceplan" {
  name                = "${azurerm_resource_group.rg.name}-plan"
  location            = "${azurerm_resource_group.rg.location}" 
  resource_group_name = "${azurerm_resource_group.rg.name}"
  kind                = var.service_plan_kind
  workerSize          = var.workerSize
  workerSizeId        = var.workerSizeId
  numberOfWorkers     = var.numberOfWorkers
  reserved            = true #if not set, will create a windows plan even though the 'kind' is Linux.

  sku {
    tier  = var.tier
    size  = var.size
  }
}*/