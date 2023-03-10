data "azurerm_virtual_network" "vnet" {
    name                = var.vmnet
    resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "public" {
  name                 = "711_POC_AD_Public"
  resource_group_name  = var.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.11.168.128/26"]

  delegation {
    name = "databricks_public"

    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action","Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}
resource "azurerm_subnet" "private" {
    name                 = "711_POC_AD_private"
    resource_group_name  = var.resource_group_name
    virtual_network_name = data.azurerm_virtual_network.vnet.name
    address_prefixes     = ["10.11.168.64/26"]

    delegation {
        name = "databricks_private"

        service_delegation {
        name    = "Microsoft.Databricks/workspaces"
        actions = ["Microsoft.Network/virtualNetworks/subnets/join/action","Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
        }
  }
}
resource "azurerm_network_security_group" "nsg2" {
    name                = "711-databricks-nsg"
    location            = var.location
    resource_group_name = var.resource_group_name
}

resource "azurerm_databricks_workspace" "databricks" {
    name                = var.workspace_name
    resource_group_name = var.resource_group_name
    location            = var.location
    sku                 = var.databricks_sku
    public_network_access_enabled = true
    custom_parameters {
        no_public_ip  = true
        public_subnet_name =  azurerm_subnet.public.name
        public_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsga_public.id
        private_subnet_name = azurerm_subnet.private.name  
        private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.nsga_private.id
        virtual_network_id  = data.azurerm_virtual_network.vnet.id
    }
}

resource "azurerm_subnet_network_security_group_association" "nsga_public" {
    network_security_group_id = azurerm_network_security_group.nsg2.id
    subnet_id = azurerm_subnet.public.id
}

resource "azurerm_subnet_network_security_group_association" "nsga_private" {
    network_security_group_id = azurerm_network_security_group.nsg2.id
    subnet_id = azurerm_subnet.private.id
}

resource "databricks_cluster" "shared_autoscaling" {
    cluster_name            = var.cluster_name
    spark_version           = var.spark_version
    node_type_id            = "Standard_DS3_v2"
    autotermination_minutes = 10
    autoscale {
        min_workers = 1
        max_workers = 3
    }

#   library {
#     pypi {
#         package = var.pythonpackage
#         // repo can also be specified here
#         }

#     }
    dynamic "library" {
        for_each = toset(var.pythonpackage)
        content {
            pypi {
                package = library.value
            }
        }
    }
  
    custom_tags = {
        Department = "Engineering"
    }
}
resource "databricks_token" "pat" {
    provider = databricks
    comment  = "Terraform Provisioning"
    // 100 day token
    lifetime_seconds = 8640000
}

output "url" {
  description = "Name of the location"
  value       = azurerm_databricks_workspace.databricks.workspace_url
}

output "pat" {
  description = "Name of the location"
  value       = databricks_token.pat.token_value
  sensitive = true
}