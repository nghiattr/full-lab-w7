output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "name-jenkins-gitlab" {
  value = azurerm_linux_virtual_machine.jenkins-gitlab-sv.name

}

output "ippub-jenkins-gitlab" {
  value = azurerm_linux_virtual_machine.jenkins-gitlab-sv.public_ip_address
}

output "name-awx" {
  value = azurerm_linux_virtual_machine.centos-vm.name

}

output "ippub-awx" {
  value = azurerm_linux_virtual_machine.centos-vm.public_ip_address
}

output "name-arc" {
  value = azurerm_container_registry.acrk8s.name

}

output "name-aks" {
  value = azurerm_kubernetes_cluster.k8s-cluster.name
}