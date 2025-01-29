# Manually Provisioning Steps

## First Time Setup
1. Have a fresh AWS account
2. Have a login to it
3. Create an S3 bucket for it to host terraform state
4. Use the CLI to enable service access
```
aws organizations enable-aws-service-access --service-principal cloudtrail.amazonaws.com
aws organizations enable-aws-service-access --service-principal "monitoring.amazonaws.com"

```
You can verify by:
```
aws organizations list-aws-service-access-for-organization
```
<!-- In Progress -->
<!-- 4. Create a pgp key -->
<!-- 5. Upload the pgp key to the S3 bucket -->
6. `terraform apply -target="module.first-time-setup" -var="github_repo=user/repo" -var="github_token=<token>" -var="<bucket-name>" -var="target_workflow=whatever"

## Subsequent provisioning steps
1. Download the student roster from Code:You, Expected output is an excel spreadsheet or similar
2. *Add column headers to the spreadsheet for (name, email, class)
3. Optional: 
    - Export the data as csv data, add it to Github Secrets as the variable `STUDENT_DATA`
    - Run workflow `Upload Student Roster`
    - This will place the roster into a location in S3 that should trigger a lambda function to auto-convert it to json and place the output as a json in a different location in the S3
4. Ensure that `students.json` is in the S3 bucket
5. Execute `On Roster Upload - Deploy Environment` although this should happen automatically
