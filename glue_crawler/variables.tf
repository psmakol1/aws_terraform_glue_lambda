# Input variable definitions

variable "aws_region" {
  description = "AWS region for all resources."

  type    = string
  default = "us-east-1"
}

variable "sns_topic" {
  description = "Name of SNS Topic"

  type    = string
  default = "TestEmail"
}
