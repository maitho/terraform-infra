resource "aws_ecr_repository" "login-app" {
  count = var.create_ecr ? 1 : 0
  name  = lower(var.CodeRepoName)
}
