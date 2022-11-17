# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY A PYTHON FUNCTION TO AWS LAMBDA
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# ----------------------------------------------------------------------------------------------------------------------
# EXAMPLE AWS PROVIDER SETUP
# ----------------------------------------------------------------------------------------------------------------------

provider "aws" {
#  region = "us-east-1"
  region = var.aws_region
}

terraform {
  required_providers {
    archive = "~> 1.3"
  }
}

# ----------------------------------------------------------------------------------------------------------------------
# DEFINE ALREADY EXISTING SNS TOPIC
# ----------------------------------------------------------------------------------------------------------------------
data "aws_sns_topic" "topic" {
  name = var.sns_topic
}

# ----------------------------------------------------------------------------------------------------------------------
# AWS LAMBDA EXPECTS A DEPLOYMENT PACKAGE
# A deployment package is a ZIP archive that contains your function code and dependencies.
# ----------------------------------------------------------------------------------------------------------------------

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/python/main.py"
  output_path = "${path.module}/python/main.py.zip"
}

# ----------------------------------------------------------------------------------------------------------------------
# DEPLOY THE LAMBDA FUNCTION
# ----------------------------------------------------------------------------------------------------------------------

#module "lambda-function" {
#  source  = "mineiros-io/lambda-function/aws"
#  version = "~> 0.5.0"

resource "aws_lambda_function" "glue_crawler" {
  function_name = "glue_crawler"
  description   = "Example Python Lambda function that kicks off Glue Crawler"
  filename      = data.archive_file.lambda.output_path
  runtime       = "python3.8"
  handler       = "main.lambda_handler"
  timeout       = 30
  memory_size   = 128

  role = aws_iam_role.lambda_exec.arn
  
  environment {
    variables = {
      email_topic = "${data.aws_sns_topic.topic.arn}"
        }
      }
  }

# ----------------------------------------------------------------------------------------------------------------------
# CREATE AN IAM LAMBDA EXECUTION ROLE WHICH WILL BE ATTACHED TO THE FUNCTION
# ----------------------------------------------------------------------------------------------------------------------

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

#------------------------------------------------------
# ATTACH ADDITIONAL POLICIES FOR THE ROLE
#-----------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess",
    "arn:aws:iam::aws:policy/AmazonSNSFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ])
  role       = aws_iam_role.lambda_exec.name
  policy_arn = each.value
}
