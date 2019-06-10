provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "b" {
  bucket = "my-tf-test-test1-bucket"
  acl    = "private"
  policy = "${file("publicPolicy.json")}"

}
