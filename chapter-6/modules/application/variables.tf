variable "vpc_id"    {}
variable "subnets"   { type = "list"}
variable "name"      {}
variable "keypair"   {}
variable "availability_zones" {
  default = ["eu-central-1a", "eu-central-1b"]
}

variable "environment" { default = "dev" }
variable "instance_type" {
   type = "map"
   default = {
     dev = "t2.micro"
     test = "t2.medium"
     prod = "t2.large"
   }
}
variable "extra_sgs" { default = [] }
variable "extra_packages" {}
variable "external_nameserver" {}

variable "instance_count" {}
