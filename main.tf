# Get the current client configuration from the AzureRM provider.
# This is used to populate the root_parent_id variable with the
# current Tenant ID used as the ID for the "Tenant Root Group"
# Management Group.

terraform {
  backend "azurerm" {}
}

provider "azurerm" {
  alias           = "connectivity"
  subscription_id = "901b9901-ee7f-4201-8457-6e5a038e675f"
  features {}
}

provider "azurerm" {
  features {}
}

# Declare the Azure landing zones Terraform module
# and provide a base configuration.



data "azurerm_client_config" "core" {
  provider = azurerm
}

data "azurerm_client_config" "connectivity" {
  provider = azurerm.connectivity
}

module "enterprise_scale" {
  source  = "Azure/caf-enterprise-scale/azurerm"
  version = "2.0.0"

  providers = {
    azurerm              = azurerm
    azurerm.connectivity = azurerm.connectivity
    azurerm.management   = azurerm
  }
  
  root_parent_id = data.azurerm_client_config.core.tenant_id
  root_id        = var.root_id
  root_name      = var.root_name

  deploy_connectivity_resources    = var.deploy_connectivity_resources
  subscription_id_connectivity     = data.azurerm_client_config.connectivity.subscription_id
  configure_connectivity_resources = local.configure_connectivity_resources

}
