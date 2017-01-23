# Provider configuration
provider "aws" {
  region = "eu-central-1"
}

# Resource configuration
resource "aws_instance" "hello-instance" {
  ami           = "ami-9bf712f4"
  instance_type = "t2.micro"

  tags {
    Name = "hello-instance"
  }
}
