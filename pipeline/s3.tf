resource "aws_s3_bucket" "terraform_codepipeline_artifacts" {
  bucket        = "${var.env}-pipeline-artifacts-terraform"
  force_destroy = true
}
resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.terraform_codepipeline_artifacts.id
  acl    = "private"
}
