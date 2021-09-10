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
  name                          = "${var.cosmos_db_account_name}"
  location                      = "${azurerm_resource_group.rg.location}"
  resource_group_name           = "${azurerm_resource_group.rg.name}"
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  enable_automatic_failover     = true
  consistency_policy {
    consistency_level           = "Session"
  }
  geo_location {
    location = "${var.failover_location}"
    failover_priority           = 1
  }
  geo_location {
    location = "${var.resource_group_location}"
    failover_priority           = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "db" {
  name                = "${var.cosmos_db_name}"
  resource_group_name = "${azurerm_cosmosdb_account.acc.resource_group_name}"
  account_name        = "${azurerm_cosmosdb_account.acc.name}"
}

resource "azurerm_cosmosdb_sql_container" "coll" {
  name                = "${var.cosmos_db_container_name}"
  resource_group_name = "${azurerm_cosmosdb_account.acc.resource_group_name}"
  account_name        = "${azurerm_cosmosdb_account.acc.name}"
  database_name       = "${azurerm_cosmosdb_sql_database.db.name}"
  partition_key_path  = "${var.cosmos_db_partition_key_path}"
}

resource "azurerm_application_insights" "ai" {
  name                = "${azurerm_resource_group.rg.name}-application-insights"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_app_service_plan" "sp" {
  name                = "${azurerm_resource_group.rg.name}-service-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "FunctionApp"
  reserved = true
  sku {
    tier              = var.app_service_plan_tier
    size              = var.app_service_plan_size
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = "${lower(azurerm_resource_group.rg.name)}"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_storage_container" "sc" {
  name                  = "func-deployments"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_function_app" "app" {
  name                = "${azurerm_resource_group.rg.name}-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  app_service_plan_id = azurerm_app_service_plan.sp.id
  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "dotnet",
    WEBSITE_RUN_FROM_PACKAGE = "1",
    CosmosDbConnectionString = "${azurerm_cosmosdb_account.acc.connection_strings[0]}",
    AzureWebJobsStorage = azurerm_storage_account.sa.primary_connection_string,
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.ai.instrumentation_key,
  }
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key
  version                    = "~3"
  https_only                 = true

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"]
    ]
  }

  site_config {
    cors {
      allowed_origins = ["*"]
    }
  }
}