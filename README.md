# Manually Provisioning Steps

## First Time Setup
1. Have a fresh AWS account
2. Have a login to it
3. Create an S3 bucket for it
4. Create a pgp key
5. Upload the pgp key to the S3 bucket
6. `terraform apply -target="module.first-time-setup" -var="github_repo=user/repo" -var="github_token=<token>" -var="<bucket-name>" -var="target_workflow=whatever"

## Subsequent provisioning steps
1. Download the student roster
2. *Add column headers to the roster for (name, email, class)
4. Upload `students.json` to S3 bucket
