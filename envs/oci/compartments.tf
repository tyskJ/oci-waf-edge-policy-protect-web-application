/************************************************************
Compartment - workload
************************************************************/
resource "oci_identity_compartment" "workload" {
  compartment_id = var.tenancy_ocid
  name           = "oci-waf-edge-policy-protect-web-application"
  description    = "For OCI Waf Edge Policy Protect Web Application"
  enable_delete  = true
}