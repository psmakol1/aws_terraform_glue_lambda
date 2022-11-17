"""Python AWS Lambda Glue Crawler
"""
import os
import boto3
from botocore.exceptions import ClientError

message = "The Glue Crawler has started"
subject = "Email from Glue admin"
    
def lambda_handler(event, context):
   # Create an SNS client
   sns = boto3.client('sns')
   # Create Glue Session
   session = boto3.session.Session()
   glue_client = session.client('glue')
   try:
      response = glue_client.start_crawler(Name = event['crawler_name'])
   # Look for errors if crawler is already ru   
   except ClientError as e:
      raise Exception("boto3 client error in start_a_crawler: " + e.__str__())
   except Exception as e:
      raise Exception("Unexpected error in start_a_crawler: " + e.__str__())
   # Publish a simple message to the specified SNS topic   
   response_email = sns.publish(
     TopicArn=os.environ['email_topic'],
     Message=message,
     Subject=subject
     
   )
   return response
