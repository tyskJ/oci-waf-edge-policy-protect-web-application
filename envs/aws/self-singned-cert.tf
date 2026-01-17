/************************************************************
Root CA Certificate
************************************************************/
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name  = "Root CA"
    organization = "${var.domain_name} Org"
  }
  validity_period_hours = 87600 # 10年
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing", # この証明書は他の証明書に署名するために使用できる
    "crl_signing",  # この証明書は証明書失効リスト（CRL）に署名するために使用できる
  ]
}

/************************************************************
Server Certificate - CSR
************************************************************/
resource "tls_private_key" "server" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "server" {
  private_key_pem = tls_private_key.server.private_key_pem
  dns_names       = ["origin.${var.domain_name}"] # SAN
  subject {
    common_name  = "origin.${var.domain_name}"
    organization = "${var.domain_name} Org"
  }
}

/************************************************************
Server Certificate
************************************************************/
resource "tls_locally_signed_cert" "server" {
  cert_request_pem   = tls_cert_request.server.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 8760 # 1年

  allowed_uses = [
    # TLS鍵交換に使用
    "key_encipherment",
    # サーバーが署名で正当性を証明
    "digital_signature",
    # TLSサーバー（HTTPS）用途
    "server_auth",
  ]
}

/************************************************************
PEM出力（CA / Server）
************************************************************/
resource "local_file" "ca_cert_pem" {
  filename        = "${path.module}/../.key/ca_crt.pem"
  content         = tls_self_signed_cert.ca.cert_pem
  file_permission = "0644"
}

resource "local_file" "server_cert_pem" {
  filename        = "${path.module}/../.key/server_crt.pem"
  content         = tls_locally_signed_cert.server.cert_pem
  file_permission = "0644"
}

resource "local_file" "server_key_pem" {
  filename        = "${path.module}/../.key/server_key.pem"
  content         = tls_private_key.server.private_key_pem
  file_permission = "0600"
}