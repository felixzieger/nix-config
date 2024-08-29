# Cloud-Init file
locals {
  # return var.cloud_init_template_path if it's not null
  # otherwise return "${path.module}/templates/cloud-init.yaml.tpl"
  cloud_init_template_file = coalesce(var.cloud_init_template_file, "${path.module}/templates/cloud-init.yaml.tpl")
}

# ssh keys
resource "random_uuid" "random_id" {}

# Output: A randomly generated uuid
output "random_uuid" {
  value     = random_uuid.random_id.result
  sensitive = false
}
