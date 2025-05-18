provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2_instance" {
  ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI (for us-east-1)
  instance_type = "t2.micro"
  key_name      = "mykey"                  # Must match the key name in AWS

  tags = {
    Name = "JenkinsTerraformInstance"
  }
}
