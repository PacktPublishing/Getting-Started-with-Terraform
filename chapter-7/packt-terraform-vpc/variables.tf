variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "subnet_cidrs" {
  description = "CIDR blocks for public and private subnets"
  default = {
    "eu-central-1a-public" = "10.0.1.0/24",
    "eu-central-1a-private" = "10.0.2.0/24",
    "eu-central-1b-public" = "10.0.3.0/24",
    "eu-central-1b-private" = "10.0.4.0/24"
  }
}

