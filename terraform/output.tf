output "aws_instances" {

  value = [for instance in aws_instance.test_env_ec2 : instance.public_ip]

}
