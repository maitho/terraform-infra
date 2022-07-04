variable "aws_region" { type = string }
variable "CodeRepoOwner" { type = string }
variable "CodeRepoOauthToken" { type = string }
variable "github_organization" {
  type    = string
  default = "maitho"
}
variable "env" {
  type    = string
  default = "dev"
}
variable "StackName" { type = string }
variable "CodeRepoURL" { type = string }
variable "CodeRepoName" { type = string }
variable "CodeRepoBranch" { type = string }
variable "CodeRepoTag" { type = string }
variable "image_tag" { type = string }
variable "create_ecr" { type = string }
variable "environment_variables" {
  type = list(object({
    env_name  = string
    env_value = string
  }))
}
variable "build_spec_file" {
  type    = string
  default = "buildspec.yml"
}
variable "compute_type" {
  type    = string
  default = "BUILD_GENERAL1_SMALL"
}
