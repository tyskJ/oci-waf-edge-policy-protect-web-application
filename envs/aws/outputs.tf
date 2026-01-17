output "ssh_command" {
  value = "ssh -i ../.key/keypair.pem ec2-user@${aws_eip.this.public_ip}"
}