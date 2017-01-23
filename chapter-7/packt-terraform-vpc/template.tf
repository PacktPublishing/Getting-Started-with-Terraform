resource "aws_vpc" "my-vpc" {
  cidr_block = "${var.vpc_cidr}"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.my-vpc.id}"
}

resource "aws_default_route_table" "default_routing" {
  default_route_table_id = "${aws_vpc.my-vpc.default_route_table_id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

resource "aws_subnet" "public-1" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  availability_zone = "eu-central-1a"
  cidr_block = "${lookup(var.subnet_cidrs, "eu-central-1a-public")}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public-2" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  availability_zone = "eu-central-1b"
  cidr_block = "${lookup(var.subnet_cidrs, "eu-central-1b-public")}"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private-1" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  availability_zone = "eu-central-1a"
  cidr_block = "${lookup(var.subnet_cidrs, "eu-central-1a-private")}"
}

resource "aws_subnet" "private-2" {
  vpc_id = "${aws_vpc.my-vpc.id}"
  availability_zone = "eu-central-1b"
  cidr_block = "${lookup(var.subnet_cidrs, "eu-central-1b-private")}"
}

output "public-subnet-1-id" {
  value = "${aws_subnet.public-1.id}"
}

output "public-subnet-2-id" {
  value = "${aws_subnet.public-2.id}"
}

output "vpc_id" {
  value = "${aws_vpc.my-vpc.id}"
}
