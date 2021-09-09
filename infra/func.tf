resource "random_string" "random" {
  length  = 4
  special = false
  lower   = true
  upper   = false
}

resource "azurerm_storage_account" "func_storage_acc" {
  name                     = "funcstorageacc${random_string.random.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  depends_on = [azurerm_resource_group.rg]
}

resource "azurerm_storage_container" "func_storage_container" {
  name                  = "func-deployments"
  storage_account_name  = azurerm_storage_account.func_storage_acc.name
  container_access_type = "private"

  depends_on = [azurerm_resource_group.rg]
}


module "func" {
  source                    = "./modules/func"
  RESOURCE_GROUP            = var.resource_group_name
  LOCATION                  = var.resource_group_location
  STORAGE_ACC_NAME          = azurerm_storage_account.func_storage_acc.name
  STORAGE_ACC_KEY           = azurerm_storage_account.func_storage_acc.primary_access_key
  STORAGE_CONNECTION_STRING = azurerm_storage_account.func_storage_acc.primary_blob_connection_string

  depends_on = [azurerm_resource_group.rg]
}