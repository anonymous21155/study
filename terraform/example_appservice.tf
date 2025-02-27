terraform {
  required_providers {
    azurerm {
        version = "~>3.0"
        source = "hashicorp/azurerm
    }
  }
}

providers "azurerm" {
    features {}
}

resource "azurerm_reosurce_group" "myRG"{
    location = "East US"
    name = "myRG"
    tags = {
        env = "prod"
    }
}

resource "azurerm_service_plan" {
    name = "myAPPServicePlan"
    location = azurerm_resource_group.myRG.location
    resource_group_name = azurerm_reosurce_group.myRG.name
    os_type = "Linux"
    sku_name = "F1"

}

resource "azurerm_linux_web_app" "myAPP" {
  name = "myAPP"
  service_plan_id = azurerm_service_plan.id
  location = azurerm_reosurce_group.myRG.location
  resource_group_name = azurerm_reosurce_group.myRG.name
  site_config {
    always_on = true
    application_stack {
      current_stack = "node"
      node_version = "18-lts"
    }
  }
  app_settings {
    "ENV" = "production"
  }
}