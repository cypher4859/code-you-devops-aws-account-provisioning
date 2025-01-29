import boto3
import os
import json


def lambda_handler(event, context):
    region = os.environ.get("ROOT_CLOUDWATCH_TARGET_REGION")
    subaccount_role_arn = os.environ.get("SUB_ACCOUNT_ROLE_ARN")
    
    # Assume the Sub-Account Role
    sts_client = boto3.client("sts")
    assumed_role = sts_client.assume_role(
        RoleArn=subaccount_role_arn,
        RoleSessionName="CrossAccountSession"
    )

    credentials = assumed_role["Credentials"]

    # Use assumed credentials to access Sub-Account
    ec2_client = boto3.client(
        "ec2",
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"]
    )

    cloudwatch_client = boto3.client(
        "cloudwatch",
        aws_access_key_id=credentials["AccessKeyId"],
        aws_secret_access_key=credentials["SecretAccessKey"],
        aws_session_token=credentials["SessionToken"]
    )

    # Get all running instances in the Sub-Account
    instances = ec2_client.describe_instances(
        Filters=[{"Name": "instance-state-name", "Values": ["running"]}]
    )
    instance_ids = [
        instance["InstanceId"]
        for reservation in instances["Reservations"]
        for instance in reservation["Instances"]
    ]

    # Update CloudWatch Dashboard in Root Account
    # root_cloudwatch = boto3.client("cloudwatch")
    widgets = [
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    # Explicitly set the InstanceId dimension and add a label for each instance
                    ["AWS/EC2", "CPUUtilization", "InstanceId", instance_id, { "label": f"Instance {instance_id}" }]
                    for instance_id in instance_ids
                ] + [
                    # Add a metric math expression to calculate the total CPU hours
                    [{ "expression": "SUM(METRICS())", "label": "Total CPU Hours" } ]
                ],
                "view": "timeSeries",
                "region": region,
                "stacked": False,
                "title": "CPU Utilization per Instance"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    # Explicitly set the InstanceId dimension and add a label for each instance
                    ["AWS/EC2", "MemoryUtilization", "InstanceId", instance_id, { "label": f"Memory {instance_id}" }]
                    for instance_id in instance_ids
                ],
                "view": "timeSeries",
                "region": region,
                "stacked": False,
                "title": "Memory Utilization per Instance"
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 0,
            "width": 12,
            "height": 6,
            "properties": {
                "metrics": [
                    # Explicitly set the InstanceId dimension and add a label for each instance
                    ["AWS/EC2", "StatusCheckFailed", "InstanceId", instance_id, { "label": f"Health {instance_id}" }]
                    for instance_id in instance_ids
                ],
                "view": "timeSeries",
                "region": region,
                "stacked": False,
                "title": "Failed Health per Instance"
            }
        }
    ]

    cloudwatch_client.put_dashboard(
        DashboardName="CrossAccount-EC2-Monitoring",
        DashboardBody=json.dumps({"widgets": widgets})
    )

    return {"status": "success", "monitored_instances": instance_ids}

if __name__ == "__main__":
    lambda_handler({}, {})
