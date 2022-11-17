# aws_terraform_glue_lambda
This pattern demonstrates serverless ETL, event driven ETL service which uses Lambda to kick off Glue Crawler and informs corresponding team member 
on successful starts by sending an email via SNS Queue. Once crawler process completes, Eventbridge service monitors the completion of the Crawler 
and kicks off another Lambda function. The whole process is written using Terraform scripts to manage and provision the infrastructure for this process.

