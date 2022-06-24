output "ssm_parameters" {
    value =  [for v in aws_ssm_parameter.ssm_parameters: join(":",[v.name,v.version])]
}