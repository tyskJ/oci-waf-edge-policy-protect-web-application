/************************************************************
Certificates for Edge Policy
************************************************************/
resource "oci_waas_certificate" "this" {
  compartment_id                 = oci_identity_compartment.workload.id
  display_name                   = "origin-cert"
  certificate_data               = file("${path.module}/../.key/server_crt.pem")
  private_key_data               = file("${path.module}/../.key/server_key.pem")
  is_trust_verification_disabled = true # Self-signed Certificates
  defined_tags                   = local.common_defined_tags
}