output "ssm" {
  value = {
    for n, p in data.aws_ssm_parameter.dynamic : n => p.name
  }
}
output "cfn-git-2-s3" {
  value = {
    for n, p in data.aws_cloudformation_stack.git-2-s3 : n => p.outputs["OutputBucketName"]
  }
}
