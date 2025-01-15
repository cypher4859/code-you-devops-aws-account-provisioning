import os
import boto3
from botocore.exceptions import NoCredentialsError, PartialCredentialsError, ClientError

def test_iam_user_login(access_key_id, secret_access_key, region):
    try:
        # Create a session using the IAM user's credentials
        session = boto3.Session(
            aws_access_key_id=access_key_id,
            aws_secret_access_key=secret_access_key,
            region_name=region
        )
        
        # Use the session to call the AWS STS service
        sts_client = session.client("sts")
        response = sts_client.get_caller_identity()
        
        # Print the caller identity to verify successful login
        print("Login successful!")
        print(f"Account: {response['Account']}")
        print(f"User ARN: {response['Arn']}")
    
    except NoCredentialsError:
        print("Error: No credentials provided.")
    except PartialCredentialsError:
        print("Error: Incomplete credentials provided.")
    except ClientError as e:
        print(f"Error: {e.response['Error']['Message']}")

# Replace these with the new user's credentials
ACCESS_KEY_ID = os.environ.get("E2E_ACCESS_KEY")
SECRET_ACCESS_KEY = os.environ.get("E2E_SECRET_KEY")
DEFAULT_REGION = os.environ.get("AWS_DEFAULT_REGION", "us-east-2")

# Call the function
test_iam_user_login(ACCESS_KEY_ID, SECRET_ACCESS_KEY, DEFAULT_REGION)
