terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.14.0"
    }
    databricks = {
      source = "databrickslabs/databricks"
      version = "0.3.0"
    }
     azuread = {    
    source = "hashicorp/azuread"    
    }
  }
  backend "azurerm" {
    resource_group_name  = "mlops-RnD-RG"
    storage_account_name = "711terraformbackend"
    container_name       = "7-11-tfstate"
    key                  = "terraform.tfstate"
  
  }
}
provider "azurerm" {
  features {}

  # subscription_id = "a118f0cc-4095-4943-b42b-21b474db8465"
  # tenant_id       = "927e65b8-7ad7-48db-a3c6-c42a67c100d6"
}
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.databricks.id
  host = azurerm_databricks_workspace.databricks.workspace_url
}
