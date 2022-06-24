resource "aws_ssm_parameter" "ssm_parameters" {
  for_each  = { for v in var.params.ssm : v.name => v.paramValue }
  type      = "String"
  name      = each.key
  value     = each.value
  overwrite = true
}

resource "aws_cloudformation_stack" "ssm" {
  name = "tf-ssm-paramter-stack${var.stack_name_prefix}"

  template_body = <<STACK

  Resources:
    BasicParameter${replace(var.stack_name_prefix, "-", "")}:
      Type: AWS::SSM::Parameter
      Properties:
        Name: sample-name${var.stack_name_prefix}
        Type: String
        Value: sample-name

  Outputs:
    %{for v in aws_ssm_parameter.ssm_parameters}
    ${replace(replace(v.name, "/", ""), "-", "")}:
      Value: ${join(":", [v.name, v.version])}
      Export:
        Name: ${replace(v.name, "/", "-")}
    %{endfor}

STACK
}
