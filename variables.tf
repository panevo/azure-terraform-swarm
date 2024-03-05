variable "name_postfix" {
  description = <<EOF
    Postfix to add to resource names. Useful when testing terraform code and you don't
    want the deployed resources to clash with 'live' resources.
  EOF
  default     = ""
}

variable "ssh_private_key_local_path" {
  description = <<EOF
    Local path where you plan to place the generated SSH private key. The path to the
    SSH private key is needed when generating the ansible inventory file.
  EOF
}
