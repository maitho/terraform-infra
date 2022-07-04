# see https://registry.terraform.io/providers/integrations/github/latest/docs
provider "github" {
  token = data.aws_ssm_parameter.CodeRepoOauthToken.value
  owner = var.github_organization
}
resource "github_repository_webhook" "this" {
  repository = var.CodeRepoName

  configuration {
    url          = aws_codepipeline_webhook.this.url
    content_type = "json"
    insecure_ssl = false
    secret       = data.aws_ssm_parameter.CodeRepoOauthToken.value
  }
  active = true
  events = ["push"]
}
