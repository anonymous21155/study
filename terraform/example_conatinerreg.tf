terraform {
  required_providers {
    azurerm {
        source = "hashicorp/azurerm"
        version = "~>3.0"
    }
  }
}

providers "azurerm"{
    features {}
}

resource azurerm_container_registry "myACR" {
  name = "myACR"
  location = "Cananda Central"
  resource_group_name = "myRG"
  sku = "Basic"
  admin_enabled = true
}

output "myOut" {
  value = azurem_conatiner_registry.myACR.id
  description= "ACR created"
}