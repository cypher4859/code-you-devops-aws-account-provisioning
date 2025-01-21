import boto3
import json
import os

# Initialize AWS services
s3_client = boto3.client("s3", region_name=os.environ.get("AWS_REGION"))
ses_client = boto3.client("ses", region_name=os.environ.get("AWS_REGION"))
ses_email = os.environ["SES_VERIFIED_EMAIL"]
credential_bucket = os.environ["S3_BUCKET"]
credential_bucket_path= os.environ["S3_BUCKET_PATH_CREDENTIALS_FILE"]

def send_email(to_email, subject, body):
    """Send an email using Amazon SES."""
    response = ses_client.send_email(
        Source=ses_email,  # Must be a verified email in SES
        Destination={
            "ToAddresses": [to_email]
        },
        Message={
            "Subject": {"Data": subject},
            "Body": {"Text": {"Data": body}}
        }
    )
    return response

def get_user_credentials():
    """Retrieve user credentials from an S3 bucket."""
    bucket_name = credential_bucket
    key = credential_bucket_path

    response = s3_client.get_object(Bucket=bucket_name, Key=key)
    credentials = json.loads(response["Body"].read().decode("utf-8"))
    return credentials

def lambda_handler(event, context):
    """AWS Lambda function entry point."""
    try:
        credentials = get_user_credentials()

        for username, details in credentials.items():
            email = details["email"]

            # Send email with Name as username
            send_email(
                to_email=email,
                subject="Your AWS Username",
                body=(
                    f"Hello {details['name']},\n\n"
                    f"Your username is: {details['name']}\n\n"
                    f"Best regards,\nYour Admin Team"
                )
            )

            # Send email with Access Key ID
            send_email(
                to_email=email,
                subject="Your AWS Access Key ID",
                body=(
                    f"Hello {details['name']},\n\n"
                    f"Your Access Key ID is: {details['access_key_id']}\n\n"
                    f"Best regards,\nYour Admin Team"
                )
            )

            # Send email with Secret Access Key
            send_email(
                to_email=email,
                subject="Your AWS Secret Access Key",
                body=(
                    f"Hello {details['name']},\n\n"
                    f"Your Secret Access Key is: {details['secret_access_key']}\n\n"
                    f"Please keep this information secure.\n\n"
                    f"Best regards,\nYour Admin Team"
                )
            )

        return {
            "statusCode": 200,
            "body": "Emails sent successfully."
        }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": f"An error occurred: {str(e)}"
        }
