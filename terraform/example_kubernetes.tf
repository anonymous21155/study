terraform {
  required_providers {
    azurerm {
        version = "~>3.0"
        source = "hashicorp/azurerm"
    }
  }
}

providers "azurerm" {
    features{}
}

resource "azurerm_kubernetes_cluster" "myCluster" {
    name = "myCluster"
    resource_group_name = "myRG"
    location = "East US"
    dns_prefix = "myCluster"
    identity {
        type = "SystemAssigned" 
    }
    defaUlt_node_pool = {
        node_count = 3
        vm_size = "Standard DS1_V2"
        name = "default"
        zones = [1,2]
    }
    network_profile {
        loadbalancer_sku = 'basic"
        network_plugin = "azure"
    }
}