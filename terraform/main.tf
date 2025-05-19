provider "aws" {
  region = "us-east-1"
}

# Create a Security Group that allows SSH from anywhere
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH from any IP"
  vpc_id      = data.aws_vpc.default.id  # We need the default VPC

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Get the default VPC (needed to attach SG)
data "aws_vpc" "default" {
  default = true
}

# EC2 Instance
resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-084568db4383264d4"
  instance_type = "t2.micro"
  key_name      = "mykey"

  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "JenkinsTerraformInstance"
  }
}
