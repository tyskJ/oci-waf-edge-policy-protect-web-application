Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash

# Shell Options
# e : エラーがあったら直ちにシェルを終了
# u : 未定義変数を使用したときにエラーとする
# o : シェルオプションを有効にする
# pipefail : パイプラインの返り値を最後のエラー終了値にする (エラー終了値がない場合は0を返す)
set -euo pipefail

# Package Update
dnf update -y

# Timezone
timedatectl set-timezone Asia/Tokyo

# Locale
localectl set-locale LANG=ja_JP.UTF-8
localectl set-keymap jp-OADG109A

# Apach Install
dnf install -y httpd mod_ssl

# Apache Document Root settings
echo '<html><head></head><body><pre><code>' > /var/www/html/index.html
hostname >> /var/www/html/index.html
echo '' >> /var/www/html/index.html
cat /etc/os-release >> /var/www/html/index.html
echo '</code></pre></body></html>' >> /var/www/html/index.html
chown -R apache:apache /var/www/html

# Apache SSL Settings
mkdir -p /etc/pki/tls/private
mkdir -p /etc/pki/tls/certs

cat <<'EOF' > /etc/pki/tls/private/server.key
${server_key}
EOF

cat <<'EOF' > /etc/pki/tls/certs/server.crt
${server_cert}
EOF

cat <<'EOF' > /etc/pki/tls/certs/ca.crt
${ca_cert}
EOF

chmod 600 /etc/pki/tls/private/server.key

cat <<'EOF' > /etc/httpd/conf.d/ssl.conf
${ssl_conf}
EOF

# Apache Start
systemctl enable --now httpd
--//--