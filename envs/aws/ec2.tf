/************************************************************
KeyPair
************************************************************/
resource "tls_private_key" "ssh_keygen" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "keypair_pem" {
  filename        = "${path.module}/.key/keypair.pem"
  content         = tls_private_key.ssh_keygen.private_key_pem
  file_permission = "0600"
}

resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = tls_private_key.ssh_keygen.public_key_openssh
  tags = {
    Name = "keypair"
  }
}

/************************************************************
EC2
************************************************************/
resource "aws_instance" "this" {
  ami                         = data.aws_ssm_parameter.amazonlinux_2023.value
  associate_public_ip_address = true
  key_name                    = aws_key_pair.keypair.id
  instance_type               = "t3.large"
  root_block_device {
    volume_size           = 50
    volume_type           = "gp3"
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
    encrypted             = true
    tags = {
      Name = "root-volume"
    }
  }
  subnet_id = aws_subnet.this.id
  vpc_security_group_ids = [
    aws_security_group.this.id
  ]
  metadata_options {
    http_tokens = "required"
  }
  maintenance_options {
    auto_recovery = "default"
  }
  user_data = templatefile("${path.module}/userdata/linux_init.sh", {
    server_key  = tls_private_key.server.private_key_pem
    server_cert = tls_locally_signed_cert.server.cert_pem
    ca_cert     = tls_self_signed_cert.ca.cert_pem
    ssl_conf    = local_file.apache_ssl_conf.content
  })
  disable_api_stop        = false
  disable_api_termination = false
  force_destroy           = true
  tags = {
    Name = "web"
  }
  #   # userdataを変更すると再起動が走るため抑止
  #   # 代わりに、user_data_replace_on_change は効かなくなる
  #   # 本検証は即時反映させたいためコメントアウト
  #   lifecycle {
  #     ignore_changes = [ user_data ]
  #   }
}

/************************************************************
Allocateion EIP
************************************************************/
resource "aws_eip_association" "this" {
  depends_on = [
    aws_internet_gateway.this
  ]
  allocation_id = aws_eip.this.allocation_id
  instance_id   = aws_instance.this.id
}