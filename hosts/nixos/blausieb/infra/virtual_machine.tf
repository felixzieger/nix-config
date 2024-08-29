resource "oci_core_instance" "ampere_a1" {
  count               = var.oci_vm_count
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains.2.name
  compartment_id      = var.tenancy_ocid
  display_name        = "AmpereA1-0"
  shape               = var.ampere_a1_shape

  create_vnic_details {
    subnet_id        = oci_core_subnet.ampere_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    hostname_label   = format("${var.instance_prefix}-%02d", count.index + 1)
  }

  shape_config {

    memory_in_gbs = var.ampere_a1_vm_memory
    ocpus         = var.ampere_a1_cpu_core_count
  }
  source_details {
    source_type = "image"
    source_id   = local.os_images["ubuntu2204"].os_image_id
  }

  metadata = {
    ssh_authorized_keys = <<EOF
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCmx9zfsn7BMbXCbbaK/bPQaEk/26zFTMu4oqN8Fy77HCeeiqARjwPwfHjkipjn5P+CTpRjjNY1mLhCx7XJsaSAOnIyTdq/cwnD4SzTMsDm40kIY+zUjgc/j3J9XNCOhlnE6YTQADw2cf3clEQy6ngKROvThun54xsQoxh1uT6dzn+DgmC5qbjpPvfaj/wknGpWI2th083sZIoihPPknM26iWhi0wlF46BIwH93PYi52SO2TnAd6Lisxags+flv6bz0b56VuG38tUU08p5LiSoFLlNyZ3RK56wEd9R/Bds0CfF/nt2+lRxZ2hWD0IVoNsRf2pBkl6pPH2hJul34JsdvgQkV8qHLFuqbCQ9Y2+1EafYWVIaJhSBHd0X0vxxDqNHNTIReU1ZcCE27/gq6Fb9dw7BcEYRAyVJUys9nGZxsVfk0+oaFlmzNSaU9WuI7kHKKzti9WgxSVOvfZeriMijuX1hiiQNQTcnvtNQSoWqbtSESorlzLlyya/D1qt5yxM2Jz22NDtghJZzz2qRGbl9m58WNf8/QerbhK4Ip04FgJQO+htQvhBqyM1XkLd4A37FtI6DtqzmZDg8rGcuq62ZpIdk+p6Okxsrbd6kxUFbkm3l07fSTE2nfUNvpMBCoxySLxJZLF+exZEG9BoCx5hc2EabmYrjkSg10YKeQUlIq/w== felix@felix-meshpad
EOF
    #   user_data = "${base64encode(data.template_file.cloud_config.rendered)}"
    user_data = "${base64encode(file("${local.cloud_init_template_file}"))}"

  }
}
