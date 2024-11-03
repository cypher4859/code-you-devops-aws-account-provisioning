import json
import urllib3
import os

def lambda_handler(event, context):
    main()

def main():
    http = urllib3.PoolManager()
    github_token = os.getenv("GITHUB_TOKEN")
    repo_name = os.getenv("GITHUB_REPO_NAME")
    target_workflow = os.getenv("GITHUB_WORKFLOW")

    url = f"https://api.github.com/repos/{repo_name}/dispatches"

    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }

    payload = {
        "event_type": target_workflow
    }

    response = http.request('POST', url, body=json.dumps(payload), headers=headers)

    return {
        'statusCode': response.status,
        'body': response.data.decode('utf-8')
    }

if __name__ == "__main__":
    main()