# Output: map of image names and image ids
output "oci_aarch64_images_map" {
  sensitive = false
  value = zipmap(
    [
      data.oci_core_images.ubuntu-22_04-aarch64.images.0.display_name,
    ],
    [
      data.oci_core_images.ubuntu-22_04-aarch64.images.0.id,
    ]
  )
}

locals {
  oci_aarch64_images = zipmap(
    [
      data.oci_core_images.ubuntu-22_04-aarch64.images.0.display_name,
    ],
    [
      data.oci_core_images.ubuntu-22_04-aarch64.images.0.id,
    ]
  )

  oci_aarch64_image_names = tolist(keys(local.oci_aarch64_images))
  oci_aarch64_image_ids   = tolist(values(local.oci_aarch64_images))
  os_images = {
    ubuntu2204 = {
      os_image_id = data.oci_core_images.ubuntu-22_04-aarch64.images.0.id
    }
  }

}

# Output: the local map of the available oci image names and IDs
output "local_oci_aarch64_images_map" {
  value     = local.oci_aarch64_images
  sensitive = false
}

# Output: List of available OCI image names
output "local_oci_aarch64_image_names" {
  value     = local.oci_aarch64_image_names
  sensitive = false
}

# Output: List of available OCI image IDs
output "local_oci_aarch64_image_ids" {
  value     = local.oci_aarch64_image_ids
  sensitive = false
}

