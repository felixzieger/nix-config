terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  auth                = "SecurityToken"
  config_file_profile = "blausieb"
  region              = "eu-frankfurt-1"
  # tenancy_ocid        = var.tenancy_ocid
  # user_ocid           = var.user_ocid
}
