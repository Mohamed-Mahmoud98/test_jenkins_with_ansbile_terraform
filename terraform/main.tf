provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI in us-east-1 (check yours)
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleInstance"
  }
}
