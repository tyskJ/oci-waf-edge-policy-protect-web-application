locals {
  account_id     = data.aws_caller_identity.current.account_id
  region_name    = data.aws_region.current.region
  partition_name = data.aws_partition.current.partition
  apache_ssl_ciphers = join(":", [
    "TLS_AES_256_GCM_SHA384",
    "TLS_AES_128_GCM_SHA256",
    "TLS_CHACHA20_POLY1305_SHA256",
    "ECDHE-RSA-AES256-GCM-SHA384",
    "ECDHE-RSA-AES128-GCM-SHA256",
    "ECDHE-ECDSA-AES256-GCM-SHA384",
    "ECDHE-ECDSA-AES128-GCM-SHA256"
  ])
}

/************************************************************
Apache SSL Settings File
************************************************************/
resource "local_file" "apache_ssl_conf" {
  filename = "${path.module}/.settings/apache-ssl.conf"
  content  = <<EOF
<VirtualHost *:443>
    ServerName origin.${var.domain_name}
    DocumentRoot /var/www/html

    SSLEngine on
    SSLProtocol -all +TLSv1.2 +TLSv1.3
    SSLCipherSuite ${local.apache_ssl_ciphers}
    SSLHonorCipherOrder on

    SSLCertificateFile /etc/pki/tls/certs/server.crt
    SSLCertificateKeyFile /etc/pki/tls/private/server.key
    SSLCACertificateFile /etc/pki/tls/certs/ca.crt

    <Directory "/var/www/html">
        Require all granted
    </Directory>
</VirtualHost>
EOF
}