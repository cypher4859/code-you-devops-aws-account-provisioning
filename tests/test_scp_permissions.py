import boto3
import pytest
from botocore.exceptions import ClientError
import time

# Test configurations
REGION = "us-east-2"
TEST_INSTANCE_TYPE = "t2.micro"
INVALID_INSTANCE_TYPE = "t2.large"
BUCKET_NAME = "scp-test-bucket-12345"
QUEUE_NAME = "scp-test-queue"
ALARM_NAME = "scp-test-alarm"
ECS_CLUSTER_NAME = "test-ecs-cluster"
ECS_SERVICE_NAME = "test-ecs-service"
TASK_DEFINITION_NAME = "test-task-definition"
LAUNCH_TEMPLATE_NAME = "test-launch-template"
AUTOSCALING_GROUP_NAME = "test-autoscaling-group"
ALB_NAME = "test-app-load-balancer"
TARGET_GROUP_NAME = "test-target-group"
LISTENER_PORT = 80
DEFAULT_PRIMARY_SUBNET = "subnet-494a0904"
DEFAULT_SECONDARY_SUBNET = "subnet-3ca6181d"
DEFAULT_SECURITY_GROUP = "sg-e11eacd1"
DEFAULT_VPC = "vpc-1d4b8760"

# Replace these with the IAM user's access and secret keys
ACCESS_KEY = "your-access-key"
SECRET_KEY = "your-secret-access-key"


def create_aws_client(service, region=REGION):
    """Creates a boto3 client for the specified service using the provided access keys."""
    return boto3.client(
        service,
        region_name=region,
        aws_access_key_id=ACCESS_KEY,
        aws_secret_access_key=SECRET_KEY,
    )


# Test EC2 Permissions
def test_ec2_permissions():
    ec2 = create_aws_client("ec2")
    instance_id = None

    # Test launching a valid instance type
    try:
        response = ec2.run_instances(
            ImageId="ami-0c02fb55956c7d316",  # Amazon Linux 2
            InstanceType=TEST_INSTANCE_TYPE,
            MinCount=1,
            MaxCount=1,
        )
        instance_id = response["Instances"][0]["InstanceId"]
        print(f"Successfully launched a t2.micro instance: {instance_id}")
    except ClientError as e:
        pytest.fail(f"Failed to launch t2.micro instance: {e}")

    # Cleanup: Terminate the launched instance
    if instance_id:
        try:
            ec2.terminate_instances(InstanceIds=[instance_id])
            print(f"Instance {instance_id} terminated successfully.")
        except ClientError as e:
            pytest.fail(f"Failed to terminate instance {instance_id}: {e}")


# Test CloudWatch Permissions
def test_cloudwatch_permissions():
    cloudwatch = create_aws_client("cloudwatch")

    # Test creating a CloudWatch alarm
    try:
        cloudwatch.put_metric_alarm(
            AlarmName=ALARM_NAME,
            MetricName="CPUUtilization",
            Namespace="AWS/EC2",
            Statistic="Average",
            Period=300,
            EvaluationPeriods=1,
            Threshold=80.0,
            ComparisonOperator="GreaterThanThreshold",
            ActionsEnabled=False,
        )
        print(f"Successfully created a CloudWatch alarm: {ALARM_NAME}")
    except ClientError as e:
        pytest.fail(f"Failed to create CloudWatch alarm: {e}")

    # Cleanup: Delete the CloudWatch alarm
    try:
        cloudwatch.delete_alarms(AlarmNames=[ALARM_NAME])
        print(f"Successfully deleted CloudWatch alarm: {ALARM_NAME}")
    except ClientError as e:
        pytest.fail(f"Failed to delete CloudWatch alarm: {e}")


# Test SQS Permissions
def test_sqs_permissions():
    sqs = create_aws_client("sqs")
    queue_url = None

    # Test creating an SQS queue
    try:
        response = sqs.create_queue(QueueName=QUEUE_NAME)
        queue_url = response["QueueUrl"]
        print(f"Successfully created SQS queue: {QUEUE_NAME} with URL {queue_url}")
    except ClientError as e:
        pytest.fail(f"Failed to create SQS queue: {e}")

    # Cleanup: Delete the SQS queue
    if queue_url:
        try:
            sqs.delete_queue(QueueUrl=queue_url)
            print(f"Successfully deleted SQS queue: {QUEUE_NAME}")
        except ClientError as e:
            pytest.fail(f"Failed to delete SQS queue: {e}")


# Test ECS Cluster
def test_ecs_cluster():
    ecs = create_aws_client("ecs")

    # Test creating an ECS cluster
    try:
        ecs.create_cluster(clusterName=ECS_CLUSTER_NAME)
        print(f"Successfully created ECS cluster: {ECS_CLUSTER_NAME}")
    except ClientError as e:
        pytest.fail(f"Failed to create ECS cluster: {e}")

    # Cleanup: Delete ECS cluster
    try:
        ecs.delete_cluster(cluster=ECS_CLUSTER_NAME)
        print(f"Successfully deleted ECS cluster: {ECS_CLUSTER_NAME}")
    except ClientError as e:
        pytest.fail(f"Failed to delete ECS cluster: {e}")


# Test ECS Service and Task Definition
def test_ecs_service_and_task():
    ecs = create_aws_client("ecs")
    task_definition_arn = None
    service_arn = None
    cluster_arn = None
    is_failed = None

    try:
        # Register a Task Definition
        response = ecs.register_task_definition(
            family=TASK_DEFINITION_NAME,
            networkMode="awsvpc",
            containerDefinitions=[
                {
                    "name": "test-container",
                    "image": "amazonlinux",
                    "memory": 128,
                    "cpu": 128,
                    "essential": True,
                }
            ],
            requiresCompatibilities=["FARGATE"],
            cpu="256",
            memory="512",
        )
        task_definition_arn = response["taskDefinition"]["taskDefinitionArn"]
        print(f"Successfully registered task definition: {TASK_DEFINITION_NAME}")

        # Create ECS Cluster
        response = ecs.create_cluster(clusterName=ECS_CLUSTER_NAME)
        cluster_arn = response["cluster"]["clusterArn"]
        print(f"Successfully created ECS cluster: {ECS_CLUSTER_NAME}, ARN: {cluster_arn}")

        # Wait for the cluster to become active
        print(f"Waiting for ECS cluster {ECS_CLUSTER_NAME} to become ACTIVE...")
        for _ in range(30):
            clusters = ecs.describe_clusters(clusters=[ECS_CLUSTER_NAME])
            cluster_status = clusters["clusters"][0]["status"]
            if cluster_status == "ACTIVE":
                print(f"ECS cluster {ECS_CLUSTER_NAME} is now ACTIVE.")
                break
            time.sleep(10)
        else:
            print("Cluster did not become ACTIVE. Exiting test.")
            return

        # Create ECS Service
        response = ecs.create_service(
            cluster=ECS_CLUSTER_NAME,
            serviceName=ECS_SERVICE_NAME,
            taskDefinition=task_definition_arn,
            desiredCount=1,
            launchType="FARGATE",
            networkConfiguration={
                "awsvpcConfiguration": {
                    "subnets": [DEFAULT_PRIMARY_SUBNET],
                    "securityGroups": [DEFAULT_SECURITY_GROUP],
                    "assignPublicIp": "ENABLED",
                }
            },
        )
        service_arn = response["service"]["serviceArn"]
        print(f"Successfully created ECS service: {ECS_SERVICE_NAME}")
    except ClientError as e:
        is_failed = f"Failed to create ECS service or task: {e}"
    finally:
        # Cleanup
        if service_arn:
            try:
                ecs.delete_service(cluster=ECS_CLUSTER_NAME, service=ECS_SERVICE_NAME, force=True)
                waiter = ecs.get_waiter("services_inactive")
                waiter.wait(
                    cluster=ECS_CLUSTER_NAME,
                    services=[ECS_SERVICE_NAME],
                    WaiterConfig={"Delay": 10, "MaxAttempts": 30},
                )
                print(f"Successfully deleted ECS service: {ECS_SERVICE_NAME}")
            except ClientError as e:
                print(f"Failed to delete ECS service: {ECS_SERVICE_NAME}: {e}")

        if cluster_arn:
            try:
                ecs.delete_cluster(cluster=ECS_CLUSTER_NAME)
                print(f"Successfully deleted ECS cluster: {ECS_CLUSTER_NAME}")
            except ClientError as e:
                print(f"Failed to delete ECS cluster: {ECS_CLUSTER_NAME}: {e}")

        if task_definition_arn:
            try:
                ecs.deregister_task_definition(taskDefinition=task_definition_arn)
                print(f"Successfully deregistered task definition: {TASK_DEFINITION_NAME}")
            except ClientError as e:
                print(f"Failed to deregister task definition: {TASK_DEFINITION_NAME}: {e}")

        if is_failed:
            pytest.fail(is_failed)


# Test Launch Template and Auto Scaling Group
def test_launch_template_and_asg():
    ec2 = create_aws_client("ec2")
    autoscaling = create_aws_client("autoscaling")
    launch_template_id = None
    auto_scaling_group = None
    is_fail = None

    try:
        # Create Launch Template
        response = ec2.create_launch_template(
            LaunchTemplateName=LAUNCH_TEMPLATE_NAME,
            LaunchTemplateData={
                "ImageId": "ami-0c02fb55956c7d316",
                "InstanceType": "t2.micro",
            },
        )
        launch_template_id = response["LaunchTemplate"]["LaunchTemplateId"]
        print(f"Successfully created launch template: {LAUNCH_TEMPLATE_NAME}")

        # Create Auto Scaling Group
        autoscaling.create_auto_scaling_group(
            AutoScalingGroupName=AUTOSCALING_GROUP_NAME,
            LaunchTemplate={"LaunchTemplateId": launch_template_id},
            MinSize=1,
            MaxSize=2,
            DesiredCapacity=1,
            VPCZoneIdentifier=DEFAULT_PRIMARY_SUBNET,
        )
        print(f"Successfully created Auto Scaling Group: {AUTOSCALING_GROUP_NAME}")
    except ClientError as e:
        is_fail = f"Failed to create Launch Template or Auto Scaling Group: {e}"
    finally:
        # Cleanup
        if auto_scaling_group:
            try:
                autoscaling.delete_auto_scaling_group(AutoScalingGroupName=AUTOSCALING_GROUP_NAME, ForceDelete=True)
                print(f"Successfully deleted Auto Scaling Group: {AUTOSCALING_GROUP_NAME}")
            except ClientError as e:
                is_fail = f"Failed to delete Auto Scaling Group: {e}"

        if launch_template_id:
            try:
                ec2.delete_launch_template(LaunchTemplateId=launch_template_id)
                print(f"Successfully deleted launch template: {LAUNCH_TEMPLATE_NAME}")
            except ClientError as e:
                is_fail = f"Failed to delete launch template: {e}"

        if is_fail:
            pytest.fail(is_fail)


# Test Application Load Balancer
def test_application_load_balancer():
    elbv2 = create_aws_client("elbv2")
    alb_arn = None
    target_group_arn = None
    is_fail = None

    try:
        # Create Target Group
        response = elbv2.create_target_group(
            Name=TARGET_GROUP_NAME,
            Protocol="HTTP",
            Port=80,
            VpcId=DEFAULT_VPC,
        )
        target_group_arn = response["TargetGroups"][0]["TargetGroupArn"]
        print(f"Successfully created Target Group: {TARGET_GROUP_NAME}")

        # Create Load Balancer
        response = elbv2.create_load_balancer(
            Name=ALB_NAME,
            Subnets=[DEFAULT_PRIMARY_SUBNET, DEFAULT_SECONDARY_SUBNET],
            SecurityGroups=[DEFAULT_SECURITY_GROUP],
            Scheme="internet-facing",
            Type="application",
            IpAddressType="ipv4",
        )
        alb_arn = response["LoadBalancers"][0]["LoadBalancerArn"]
        print(f"Successfully created Application Load Balancer: {ALB_NAME}")
    except ClientError as e:
        is_fail = f"Failed to create ALB or Target Group: {e}"
    finally:
        # Cleanup
        if alb_arn:
            try:
                elbv2.delete_load_balancer(LoadBalancerArn=alb_arn)
                print(f"Successfully deleted Application Load Balancer: {ALB_NAME}")
            except ClientError as e:
                is_fail = f"Failed to delete ALB: {e}"

        if target_group_arn:
            try:
                elbv2.delete_target_group(TargetGroupArn=target_group_arn)
                print(f"Successfully deleted Target Group: {TARGET_GROUP_NAME}")
            except ClientError as e:
                is_fail = f"Failed to delete Target Group: {e}"

        if is_fail:
            pytest.fail(is_fail)