config {
  module     = true
}

rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

plugin "aws" {
    enabled = true
    version = "0.5.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}
