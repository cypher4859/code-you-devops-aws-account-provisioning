import unittest
from unittest.mock import patch
from moto import mock_aws
import boto3
import os
import json
from main import main  # Assuming your main function is in a file named "main.py"

class TestCSVToJsonConversion(unittest.TestCase):
    @mock_aws
    def test_main_function(self):
        test_cases = [
            {
                "bucket_key": "environment/aws/management/data-uploads/roster/csv/students/students.csv",
                "json_prefix": "environment/aws/management/data-uploads/roster/json/students/",
                "output_file": "students.json",
                "csv_data": """name,email,class
Aaron Miller,aaronwmiller86@gmail.com,Introduction to AWS
Amanda Gearhart,argrt00@gmail.com,Introduction to AWS""",
                "expected_data": [
                    {
                        "name": "Aaron_Miller",
                        "email": "aaronwmiller86@gmail.com",
                        "class": "Introduction to AWS"
                    },
                    {
                        "name": "Amanda_Gearhart",
                        "email": "argrt00@gmail.com",
                        "class": "Introduction to AWS"
                    }
                ]
            },
            {
                "bucket_key": "environment/aws/management/data-uploads/roster/csv/mentors/mentors.csv",
                "json_prefix": "environment/aws/management/data-uploads/roster/json/mentors/",
                "output_file": "mentors.json",
                "csv_data": """name,email,class
John Doe,johndoe@gmail.com,Introduction to AWS
Jane Smith,janesmith@gmail.com,Introduction to AWS""",
                "expected_data": [
                    {
                        "name": "John_Doe",
                        "email": "johndoe@gmail.com",
                        "class": "Introduction to AWS"
                    },
                    {
                        "name": "Jane_Smith",
                        "email": "janesmith@gmail.com",
                        "class": "Introduction to AWS"
                    }
                ]
            }
        ]

        for case in test_cases:
            with self.subTest(case=case):
                # Patch environment variables specific to each test case
                with patch.dict(os.environ, {
                    "TARGET_BUCKET": "test-bucket",
                    "CSV_ROSTER_FILE_BUCKET_KEY": case["bucket_key"],
                    "JSON_ROSTER_FILE_PREFIX": case["json_prefix"],
                    "OUTPUT_JSON_FILE_NAME": case["output_file"]
                }):
                    # Initialize the mock S3
                    s3_client = boto3.client('s3', region_name='us-east-1')
                    s3_client.create_bucket(Bucket="test-bucket")

                    # Prepare the mock CSV data and put it in the bucket
                    s3_client.put_object(Bucket="test-bucket", Key=case["bucket_key"], Body=case["csv_data"])

                    # Run the main function
                    main()

                    # Get the JSON file from S3
                    response = s3_client.get_object(Bucket="test-bucket", Key=f"{case['json_prefix']}{case['output_file']}")
                    json_data = response['Body'].read().decode('utf-8')

                    # Verify the contents of the uploaded JSON file
                    self.assertEqual(json.loads(json_data), case["expected_data"])

if __name__ == "__main__":
    unittest.main()
