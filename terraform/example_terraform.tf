provider "azurerm" {
  features {}
}

resource "azurerm_kubernetes_cluster" "myAKS" {
  name = "myAKS"
  location = "East US"
  resource_group_name = "myRg"
  dns_prefix = "myAKS"
  default_node_pool = {
    name = "myNode"
    node_count = 1
    vm_size = "Standard_DS1_V1"
    subnet_id = "<id>"
    os_type = "Windows" #Ubuntu
    os_sku = "Windows2025"
  }
  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_policy = "azure"
    load_balancer_sku = "standard"
  }
}

outputs "kube-config' {
  value = azurerm_kuberenets_cluster.myAKS.kube_config_raw
  sensitive = true
}