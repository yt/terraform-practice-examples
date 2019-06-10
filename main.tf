provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}

resource "aws_s3_bucket" "b" {
  bucket = "${var.screenshot_bucket_name}"
  acl    = "private"
}
resource "aws_s3_bucket_policy" "b" {
  bucket = "${aws_s3_bucket.b.id}"

  policy = <<POLICY
{
  "Version": "2008-10-17",
  "Statement": [
      {
          "Sid": "AllowPublicRead",
          "Effect": "Allow",
          "Principal": {
              "AWS": "*"
          },
          "Action": "s3:GetObject",
          "Resource": "arn:aws:s3:::${var.screenshot_bucket_name}/*"
      }
  ]
}
POLICY
}