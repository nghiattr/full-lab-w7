variable "resource_group_name" {
  default     = ""
  description = "Location of the resource group."
}

variable "resource_group_location" {
  default     = ""
  description = "Location of the resource group."
}

variable "admin_username" {
  default     = "labadmin"
  description = "Admin username for all VMs"
}

variable "admin_password" {
  default     = "Password1234!"
  description = "Admin password for all VMs"
}