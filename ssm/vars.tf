variable "params" {
  type = object({
    ssm = list(any)
  })
}

variable "stack_name_prefix" {
  type    = string
  default = ""
}