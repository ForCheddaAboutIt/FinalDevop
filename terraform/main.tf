resource "aws_vpc" "test_env" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "test_env_vpc"
  }
}

resource "aws_subnet" "subnet" {
  cidr_block        = cidrsubnet(aws_vpc.test_env.cidr_block, 3, 1)
  vpc_id            = aws_vpc.test_env.id
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "test_env_gw" {
  vpc_id = aws_vpc.test_env.id
}

resource "aws_route_table" "test_env_rt" {
  vpc_id = aws_vpc.test_env.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test_env_gw.id
  }
}

resource "aws_route_table_association" "test_env_assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.test_env_rt.id
}

resource "aws_security_group" "security" {
  name = "allow-ssh-from-anywhere"

  vpc_id = aws_vpc.test_env.id

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }

  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 5000
    to_port   = 5000
    protocol  = "tcp"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.pk.private_key_pem}' > ./myKey.pem"
  }
}

resource "aws_instance" "test_env_ec2" {
  count                       = 1
  ami                         = "ami-07d9b9ddc6cd8dd30"
  instance_type               = "t2.medium"
  key_name                    = "myKey"
  security_groups             = ["${aws_security_group.security.id}"]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.subnet.id

  tags = {
    Name = var.instance_tag2[count.index]
  }
}

resource "null_resource" "capture_ip" {
  # This resource has no other purpose than to run the local-exec provisioner
  # after each instance has been created.
  count = length(aws_instance.test_env_ec2)

  provisioner "local-exec" {
    command = <<-EOT
      echo "${aws_instance.test_env_ec2[count.index].public_ip}" > instance_ip_${count.index}.txt
      python3 dynamic_inventory.py
    EOT
  }
}
