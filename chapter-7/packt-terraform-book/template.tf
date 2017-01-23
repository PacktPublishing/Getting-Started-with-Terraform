provider "aws" {
  region = "${var.region}"
}

data "terraform_remote_state" "iam" {
  backend = "s3"
  config {
    bucket = "packt-terraform"
    key = "iam/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config {
    bucket = "packt-terraform"
    key = "vpc/terraform.tfstate"
    region = "eu-central-1"
  }
}

resource "aws_security_group" "default" {
  name = "Default SG"
  description = "Allow SSH access"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${var.allow_ssh_access}"]
  }
}

resource "aws_key_pair" "terraform" {
  key_name = "terraform"
  public_key = "${file("./id_rsa.pub")}"
}

module "mighty_trousers" {
  source = "git::https://gitlab.com/Fodoj/packt-terraform-app-module.git?ref=v0.1"
  vpc_id = "${data.terraform_remote_state.vpc.vpc_id}"
  subnets = [
             "${data.terraform_remote_state.vpc.public-subnet-1-id}",
             "${data.terraform_remote_state.vpc.public-subnet-2-id}"
            ]
  name = "MightyTrousers"
  keypair = "${aws_key_pair.terraform.key_name}"
  environment = "${var.environment}"
  extra_sgs = ["${aws_security_group.default.id}"]
  extra_packages = "${lookup(var.extra_packages, "MightyTrousers")}"
  external_nameserver = "${var.external_nameserver}"
  instance_count = 2
  iam_role = "${data.terraform_remote_state.iam.base-role-name}"
}

output "mighty_trousers_app_address" {
  value = "${module.mighty_trousers.app_address}"
}
