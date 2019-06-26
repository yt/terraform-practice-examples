provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
resource "aws_s3_bucket" "terraform_state" {
  bucket = "${var.terraform_state_bucket}"
  versioning {
    enabled = true
  }
  lifecycle {
    prevent_destroy = true
  }
}