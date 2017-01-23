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

data "aws_ami" "app-ami" {
  most_recent = true
  owners      = ["self"]
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    packages   = "${var.extra_packages}"
    nameserver = "${var.external_nameserver}"
  }
}

resource "aws_instance" "app-server" {
  ami                    = "${data.aws_ami.app-ami.id}"
  instance_type          = "${lookup(var.instance_type, var.environment)}"
  subnet_id              = "${var.subnet_id}"
  vpc_security_group_ids = ["${concat(var.extra_sgs,
aws_security_group.allow_http.*.id)}"]

  user_data = "${data.template_file.user_data.rendered}"

  key_name = "${var.keypair}"

  tags {
    Name = "${var.name}"
  }

  # provisioner "local-exec" {
  #   command = "sed -i '/\\[app-server\\]/a ${self.public_ip}' inventory"
  # }
  # provisioner "chef" {
  #   run_list = ["cookbook::recipe"]
  #   node_name = "app-server-1"
  #   server_url = "https://chef.internal/organizations/my_company"
  #   recreate_client = true
  #   user_name = "packt"
  #   user_key = "${file("packt.pem")}"
  # }
  connection {
    user        = "centos"
    private_key = "${file("/home/johndoe/.ssh/my_private_key.pem")}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo rpm -ivh http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm",
      "sudo yum install puppet -y",
    ]
  }

  lifecycle {
    ignore_changes = ["user_data"]
  }
}

resource "null_resource" "app_server_provisioner" {
  triggers {
    server_id = "${aws_instance.app-server.id}"
  }

  connection {
    user = "centos"
    host = "${aws_instance.app-server.public_ip}"
  }

  provisioner "file" {
    source      = "${path.module}/setup.pp"
    destination = "/tmp/setup.pp"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo puppet apply /tmp/setup.pp",
    ]
  }
}

output "public_ip" {
  value = "${aws_instance.app-server.public_ip}"
}
