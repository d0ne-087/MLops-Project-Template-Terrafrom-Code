variable "location" {
    type = string
    default     = "westus"
}

variable "environment" {
    type = string
    description = "project stage"
    validation {
        condition     = length(var.environment) <= 3
        error_message = "Err: Environment cannot be longer than three characters."
    }
}
variable "project" {
    type = string
    description = "update the project name as needed"
} 
variable "databricks_sku" {
    type = string
    description = "standard/premium/trial"
}

variable "resource_group_name" {
    type = string
    description = "resource group name"
}

variable "vmnet" {
    type = string
    description = "vnet name"  
}

variable "workspace_name" {
    type = string
    description = "name of the workspace getting created or updated" 
}

variable "backend_storage_name" {
    type = string
    description = "name of the storage where backend get stored"
  
}

variable "cluster_name" {
    type = string
    description = "name of the new cluster"
  
}

variable "pythonpackage" {
    type = list
    description = "python libaries needed to be added to the cluster"
  
}

variable "spark_version" {
    type = string
    description = "The cluster version with spark version"
  
}
