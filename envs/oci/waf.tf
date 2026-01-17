/************************************************************
Certificates for Edge Policy
************************************************************/
resource "oci_waas_certificate" "this" {
  compartment_id                 = oci_identity_compartment.workload.id
  display_name                   = "edge-policy-cert"
  certificate_data               = tls_locally_signed_cert.server.cert_pem
  private_key_data               = tls_private_key.server.private_key_pem
  is_trust_verification_disabled = true # Self-signed Certificates
  defined_tags                   = local.common_defined_tags
}
