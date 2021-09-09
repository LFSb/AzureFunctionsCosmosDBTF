variable "resource_group_name" {
  default = "AzureFunctionsCosmosDBTF"
}

variable "resource_group_location"{
  default = "westeurope"
}

variable "failover_location"{
  default = "northeurope"
}

variable "resource_group_environment"{
  default = "Test"
}

variable "cosmos_db_account_name"{
  default = "cosmo20210909"
}

variable "cosmos_db_name"{
  default = "Website"
}

variable "cosmos_db_container_name"{
  default = "News"
}

variable "cosmos_db_partition_key_path"{
  default = "/Date"
}