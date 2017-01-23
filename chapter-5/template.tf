provider "aws" {
  region = "${var.region}"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my_vpc.id}"
}

resource "aws_default_route_table" "default_routing" {
  default_route_table_id = "${aws_vpc.my_vpc.default_route_table_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.my_vpc.id}"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
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

module "mighty_trousers" {
  source              = "./modules/application"
  vpc_id              = "${aws_vpc.my_vpc.id}"
  subnet_id           = "${aws_subnet.public.id}"
  name                = "MightyTrousers"
  keypair             = "${aws_key_pair.terraform.key_name}"
  environment         = "${var.environment}"
  extra_sgs           = ["${aws_security_group.default.id}"]
  extra_packages      = "${lookup(var.extra_packages, "my_app", "base")}"
  external_nameserver = "${var.external_nameserver}"
}

output "mighty_trousers_public_ip" {
  value = "${module.mighty_trousers.public_ip}"
}
