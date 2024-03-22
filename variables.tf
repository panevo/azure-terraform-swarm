variable "environment" {
  description = "The environment to deploy the resources (ex: prod, staging, test)."
  default     = "test"
}

variable "name_postfix" {
  description = <<EOF
    Postfix to add to resource names. Useful when testing terraform code and you don't
    want the deployed resources to clash with 'live' resources.
  EOF
  default     = ""
}

variable "product_key" {
  description = "The product key to use in resource names."
  default     = "swarmtest"
}

variable "ssh_private_key_local_path" {
  description = <<EOF
    Local path where you plan to place the generated SSH private key. The path to the
    SSH private key is needed when generating the ansible inventory file.
  EOF
}

variable "vm_admin_username" {
  description = "The username for the VMs."
  default     = "vm_admin"
}

variable "node_manager_count" {
  description = "The number of manager nodes in the swarm cluster."
  default     = 1
}

variable "node_worker_count" {
  description = "The number of worker nodes in the swarm cluster."
  default     = 1
}

variable "node_manager_size" {
  description = "The size of the manager nodes."
  default     = "Standard_D2s_v3"
}

variable "node_worker_size" {
  description = "The size of the worker nodes."
  default     = "Standard_D2s_v3"

}
