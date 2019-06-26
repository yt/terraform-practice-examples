provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

terraform {
  backend "s3" {
    bucket = "my-tf-practice-state-bucket"
    key    = "development/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "example" {
  ami                    = "ami-40d28157"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.http_sg.id}"]
  user_data              = <<-EOF
      #!/bin/bash
      echo "Hello, World" > index.html
      nohup busybox httpd -f -p "${var.http_server_port}" &
    EOF
  tags = {
    Name = "terraform-simple-web-server"
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
}