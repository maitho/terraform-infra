data "aws_ssm_parameter" "CodeRepoOauthToken" {
  name = var.CodeRepoOauthToken
}

data "aws_ssm_parameter" "dynamic" {
  for_each = {
    for data in var.environment_variables : "${data.env_name}" => data
    if length(split("/", data.env_value)) > 1
  }
  name = each.value.env_value
}
data "aws_cloudformation_stack" "git-2-s3" {
  for_each = {
    for data in var.environment_variables : "${data.env_name}" => data
    if data.env_value == "OutputBucketName"
  }
  name = "git-2-s3"
}
