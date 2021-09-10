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
  default = "Dev"
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

variable "app_service_plan_tier"{
  default = "Dynamic"
}

variable "app_service_plan_size"{
  default = "Y1"
}