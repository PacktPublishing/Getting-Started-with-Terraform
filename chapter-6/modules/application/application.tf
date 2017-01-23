resource "aws_security_group" "allow_http" {
  name = "${var.name} allow_http"
  description = "Allow HTTP traffic"
  vpc_id = "${var.vpc_id}"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh.tpl")}"

  vars {
    packages = "${var.extra_packages}"
    nameserver = "${var.external_nameserver}"
  }
}

data "aws_ami" "app-ami" {
  most_recent = true
  owners = ["self"]
  filter {
    name = "name"
    values = ["centos-7-base-puppet*"]
  }
}

resource "aws_elb" "load-balancer" {
  name = "application-load-balancer"
  subnets = ["${var.subnets}"]
  security_groups = ["${aws_security_group.allow_http.id}"]
  cross_zone_load_balancing = true

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }
}

resource "aws_launch_configuration" "app-server" {
  image_id = "${data.aws_ami.app-ami.id}"
  instance_type = "${lookup(var.instance_type, var.environment)}"

  security_groups = ["${concat(var.extra_sgs, aws_security_group.allow_http.*.id)}"]
  key_name = "${var.keypair}"

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app-server" {
  vpc_zone_identifier = ["${var.subnets}"]
  name = "app-server-asg - ${aws_launch_configuration.app-server.name}"
  max_size = "${var.instance_count}"
  min_size = "${var.instance_count}"
  wait_for_elb_capacity = "${var.instance_count}"
  desired_capacity = "${var.instance_count}"
  health_check_grace_period = 300
  health_check_type = "ELB"
  launch_configuration = "${aws_launch_configuration.app-server.id}"
  load_balancers = ["${aws_elb.load-balancer.id}"]
  lifecycle {
    create_before_destroy = true
  }
}

output "app_address" {
  value = "${aws_elb.load-balancer.dns_name}"
}
