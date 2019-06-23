provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

data "aws_availability_zones" "all" {
  state = "available"
}

resource "aws_launch_configuration" "example" {
  image_id        = "ami-40d28157"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.http_sg.id}"]
  user_data       = <<-EOF
      #!/bin/bash
      echo "Hello, World" > index.html
      nohup busybox httpd -f -p "${var.http_server_port}" &
    EOF
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.example.id}"
  availability_zones = "${data.aws_availability_zones.all.names}"

  load_balancers = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
  tag {
    key = "Name"
    value = "terraform-asg-example"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "http_sg" {
  name = "terraform-example-sg"
  ingress {
    from_port = "${var.http_server_port}"
    to_port = "${var.http_server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "example" {
  name = "terraform-asg-example"
  availability_zones = "${data.aws_availability_zones.all.names}"
  listener {
    lb_port = 80
    lb_protocol = "http"
    instance_port = "${var.http_server_port}"
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    interval = 30
    target = "HTTP:${var.http_server_port}/"
  }
}

output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
