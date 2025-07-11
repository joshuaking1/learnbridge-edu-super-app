# Defines the AWS region variable, with a default value.
variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
  default     = "eu-west-2"
}

# Defines the project name variable, used for tagging resources.
variable "project_name" {
  description = "The name of the project, used for resource tagging."
  type        = string
  default     = "LearnBridgeEdu"
}