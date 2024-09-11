resource "oci_core_security_list" "ampere_security_list" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_virtual_network.ampere_vcn.id
  display_name   = "ampereSecurityList"

  # Protocol numbers as defined in http://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
  # TCP = 6
  # UDP = 17
  egress_security_rules {
    protocol    = "6"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "33111"
      min = "33111"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "80"
      min = "80"
    }
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"

    tcp_options {
      max = "443"
      min = "443"
    }
  }

  ingress_security_rules {
    protocol = "17"
    source   = "0.0.0.0/0"

    udp_options {
      max = "443"
      min = "443"
    }
  }
}
