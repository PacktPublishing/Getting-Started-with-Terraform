provider "aws" {
  region = "${var.region}"
}

data "aws_vpc" "management_layer" {
  id = "vpc-c36cbdab"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_vpc_peering_connection" "my_vpc-management" {
  peer_vpc_id = "${data.aws_vpc.management_layer.id}"
  vpc_id      = "${aws_vpc.my_vpc.id}"
  auto_accept = true
}

resource "aws_subnet" "public" {
  vpc_id     = "${aws_vpc.my_vpc.id}"
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "default" {
  name        = "Default SG"
  description = "Allow SSH access"
  vpc_id      = "${aws_vpc.my_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.allow_ssh_access}"]
  }
}

resource "aws_key_pair" "terraform" {
  key_name   = "terraform"
  public_key = "${file("./id_rsa.pub")}"
}

data "external" "example" {
  program = ["ruby", "${path.module}/custom_data_source.rb"]
}

module "mighty_trousers" {
  source              = "./modules/application"
  vpc_id              = "${aws_vpc.my_vpc.id}"
  subnet_id           = "${aws_subnet.public.id}"
  name                = "MightyTrousers-${data.external.example.result.owner}"
  environment         = "${var.environment}"
  extra_sgs           = ["${aws_security_group.default.id}"]
  extra_packages      = "${lookup(var.extra_packages, "my_app", "base")}"
  external_nameserver = "${var.external_nameserver}"
}
