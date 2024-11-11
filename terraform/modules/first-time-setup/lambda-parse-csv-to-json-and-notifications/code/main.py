import csv
import json
import os
import boto3

def lambda_handler(event, context):
    main()

def main():
    bucket = os.environ.get("TARGET_BUCKET")
    csv_bucket_path = os.environ.get("CSV_ROSTER_FILE_BUCKET_KEY")
    json_bucket_path = os.environ.get("JSON_ROSTER_FILE_PREFIX")
    output_json_file_name = os.environ.get("OUTPUT_JSON_FILE_NAME")

    local_json_file_path = f"/tmp/{output_json_file_name}"

    # Define the header names manually
    fieldnames = ['name', 'email']

    # Open the CSV file
    try:
        s3_client = boto3.client('s3', region_name='us-east-1')
        response = s3_client.get_object(Bucket=bucket, Key=csv_bucket_path)
        
        # Read the object's content
        csv_data = response['Body'].read().decode('utf-8').splitlines()

        # Use csv.DictReader with manual headers
        csv_reader = csv.DictReader(csv_data, fieldnames=fieldnames)
        
        # Prepare list of dictionaries for JSON
        csv_data = []
        for row in csv_reader:
            # Replace spaces in the 'name' value with underscores
            row['name'] = row['name'].replace(' ', '_')
            row['email'] = row['email'].replace('\'', '')
            row['email'] = row['email'].replace('"', '')
            csv_data.append(row)

        # Write JSON output
        json_final_bucket_destination = f"{json_bucket_path}{output_json_file_name}"
        with open(local_json_file_path, mode='w') as json_file:
            json.dump(csv_data, json_file, indent=2)

        s3_client.upload_file(local_json_file_path, bucket, f"{json_final_bucket_destination}")

        print(f"JSON data written and uploaded to s3://{bucket}/{json_final_bucket_destination}")
    except s3_client.exceptions.NoSuchKey:
        print(f"The object '{csv_bucket_path}' does not exist in bucket '{bucket}'.")
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # Clean up the temporary file if it exists
        if os.path.exists(local_json_file_path):
            os.remove(local_json_file_path)

if __name__ == "__main__":
    main()
