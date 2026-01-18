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

/************************************************************
Edge Policy (Global WAF)
************************************************************/
resource "oci_waas_waas_policy" "edge_policy" {
  compartment_id     = oci_identity_compartment.workload.id
  display_name       = "edge-policy"
  domain             = "www.${var.domain_name}"
  additional_domains = []
  origins {
    label      = "aws-origin"
    uri        = "origin.${var.domain_name}"
    http_port  = 80
    https_port = 443
  }
  defined_tags = local.common_defined_tags
  policy_config {
    is_https_enabled              = true
    certificate_id                = oci_waas_certificate.this.id
    is_https_forced               = false
    tls_protocols                 = ["TLS_V1_2", "TLS_V1_3"]
    is_sni_enabled                = false
    is_response_buffering_enabled = false
    is_cache_control_respected    = false
    is_behind_cdn                 = false
    cipher_group                  = "DEFAULT"
    client_address_header         = null
    is_origin_compression_enabled = true
    websocket_path_prefixes       = []
    health_checks {
      expected_response_code_group = ["2XX", "3XX"]
      expected_response_text       = null
      headers = {
        Host       = "www.mtdevelop.click"
        User-Agent = "waf health checks"
      }
      healthy_threshold              = 2
      interval_in_seconds            = 60
      is_enabled                     = false
      is_response_text_check_enabled = false
      method                         = "HEAD"
      path                           = "/"
      timeout_in_seconds             = 5
      unhealthy_threshold            = 2
    }
    load_balancing_method {
      domain                     = null
      expiration_time_in_seconds = 0
      method                     = "IP_HASH"
      name                       = null
    }
  }
  waf_config {
    origin        = "aws-origin"
    origin_groups = []
    address_rate_limiting {
      allowed_rate_per_address      = 1
      block_response_code           = 503
      is_enabled                    = false
      max_delayed_count_per_address = 10
    }
    device_fingerprint_challenge {
      action                                  = "DETECT"
      action_expiration_in_seconds            = 60
      failure_threshold                       = 10
      failure_threshold_expiration_in_seconds = 60
      is_enabled                              = false
      max_address_count                       = 20
      max_address_count_expiration_in_seconds = 60
      challenge_settings {
        block_action                 = "SHOW_ERROR_PAGE"
        block_error_page_code        = "DFC"
        block_error_page_description = "Access blocked by website owner. Please contact support."
        block_error_page_message     = "Access to the website is blocked."
        block_response_code          = 403
        captcha_footer               = "Enter the letters and numbers as they are shown in image above."
        captcha_header               = "We have detected an increased number of attempts to access this website. To help us keep this site secure, please let us know that you are not a robot by entering the text from the image below."
        captcha_submit_label         = "Yes, I am human."
        captcha_title                = "Are you human?"
      }
    }
    human_interaction_challenge {
      action                                  = "DETECT"
      action_expiration_in_seconds            = 60
      failure_threshold                       = 10
      failure_threshold_expiration_in_seconds = 60
      interaction_threshold                   = 3
      is_enabled                              = false
      is_nat_enabled                          = true
      recording_period_in_seconds             = 15
      challenge_settings {
        block_action                 = "SHOW_ERROR_PAGE"
        block_error_page_code        = "HIC"
        block_error_page_description = "Access blocked by website owner. Please contact support."
        block_error_page_message     = "Access to the website is blocked."
        block_response_code          = 403
        captcha_footer               = "Enter the letters and numbers as they are shown in image above."
        captcha_header               = "We have detected an increased number of attempts to access this website. To help us keep this site secure, please let us know that you are not a robot by entering the text from the image below."
        captcha_submit_label         = "Yes, I am human."
        captcha_title                = "Are you human?"
      }
    }
    js_challenge {
      action                       = "DETECT"
      action_expiration_in_seconds = 60
      are_redirects_challenged     = true
      failure_threshold            = 10
      is_enabled                   = false
      is_nat_enabled               = true
      challenge_settings {
        block_action                 = "SHOW_ERROR_PAGE"
        block_error_page_code        = "JSC-403"
        block_error_page_description = "Access blocked by website owner. Please contact support."
        block_error_page_message     = "Access to the website is blocked."
        block_response_code          = 403
        captcha_footer               = "Enter the letters and numbers as they are shown in image above."
        captcha_header               = "We have detected an increased number of attempts to access this website. To help us keep this site secure, please let us know that you are not a robot by entering the text from the image below."
        captcha_submit_label         = "Yes, I am human."
        captcha_title                = "Are you human?"
      }
      set_http_header {
        name  = "x-jsc-alerts"
        value = "{failed_amount}"
      }
    }
    protection_settings {
      allowed_http_methods               = ["GET", "POST", "HEAD", "OPTIONS"]
      block_action                       = "SHOW_ERROR_PAGE"
      block_error_page_code              = "403"
      block_error_page_description       = "Access blocked by website owner. Please contact support."
      block_error_page_message           = "Access to the website is blocked."
      block_response_code                = 403
      is_response_inspected              = false
      max_argument_count                 = 255
      max_name_length_per_argument       = 400
      max_response_size_in_ki_b          = 1024
      max_total_name_length_of_arguments = 64000
      media_types                        = ["text/html", "text/plain"]
      recommendations_period_in_days     = 10
    }
  }
}