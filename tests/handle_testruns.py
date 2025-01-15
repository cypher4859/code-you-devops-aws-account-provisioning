import json
import os
import subprocess
import sys

def run_tests_for_users(json_file):
    """Run tests for each user listed in the JSON file."""
    try:
        # Load the JSON file
        with open(json_file, "r") as f:
            credentials = json.load(f)

        # Loop through each user's credentials
        for user in credentials:
            print(f"Running tests for IAM user: {user['email']}")
            access_key = user['access_key_id']
            secret_key = user['secret_access_key']

            # Set the environment variables for the AWS SDK
            env = os.environ.copy()
            env.update({
                "AWS_ACCESS_KEY_ID": access_key,
                "AWS_SECRET_ACCESS_KEY": secret_key,
                "AWS_REGION": "us-east-1"
            })

            # Run the pytest command
            result = subprocess.run(
                ["pytest", "test_scp_permissions.py", "--verbose"],
                env=env,
                text=True
            )

            # Handle test failures
            if result.returncode != 0:
                print(f"Tests failed for user: {user['email']}")
                sys.exit(1)

        print("All tests passed successfully.")
    except FileNotFoundError:
        print(f"Error: JSON file '{json_file}' not found.")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Failed to parse JSON file '{json_file}'.")
        sys.exit(1)

if __name__ == "__main__":
    # Ensure the script is called with the correct argument
    if len(sys.argv) != 2:
        print("Usage: python handle_testruns.py <json_file>")
        sys.exit(1)

    # Run the tests
    json_file_path = sys.argv[1]
    run_tests_for_users(json_file_path)
