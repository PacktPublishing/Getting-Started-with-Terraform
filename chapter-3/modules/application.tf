variable "vpc_id" {}

variable "subnet_id" {}

variable "name" {}

resource "aws_security_group" "allow_http" {
  name        = "${var.name} allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_instance" "app-server" {
  ami                    = "ami-9bf712f4"
  instance_type          = "t2.micro"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${aws_security_group.allow_http.id}"]

  tags {
    Name = "${var.name}"
  }
}

output "hostname" {
  value = "${aws_instance.app-server.private_dns}"
}
