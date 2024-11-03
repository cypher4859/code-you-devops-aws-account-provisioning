# Code:You DevOps Provision User Accounts

NOTES:
- Need to have the csv file, by default there are no column names, manually added this in
- 

TODOs:
- [] Make the Administrator + Billing roles in management and student accounts
- [] Flesh out the SCPs
- [] Diagram this sucker
- [] Refactor to handle the .json workflow in tfvars instead of parsing the csv.
    - Basically we need an automated way to turn the csv into json and load that into tfvars
- [] Consider workflows for:
    - Need to add a student after initial provisioning
    - Need to add a mentor after initial provisioning
    - Need to remove a student (or mentor) after initial provisioning
    - Need to monitor and alarm on any/all security keys in the account and restrict creation
- [] This stuff vvv   

TODOs:
- [] Finish the Administrator and Billing Roles with access to all subaccounts
- [] Ensure that the SCPs successfully restrict subaccounts to Free-Tier
- [] 

```
├─ main.tf  
│  ├─ line 10: FIXME : This needs turned back on for a fresh account  
│  └─ line 17: TODO : Need to fill out the SCP  
└─ iam_policy_documents.tf  
    └─ line 1: TODO : Ensure that the roles from the management account can access the sub-accounts  
```

EXPECTED WORKFLOW:
1. Get the roster of students
2. Make sure the columns are (name, email, class) along with the header
3. Paste in the csv file content as a github secret in the repository
4. Run the Github Actions workflow called Provision New Students
5. viola


### What we can show:
- Create all the users and most of the IAM resources
- Execute the terraform to deploy
- Output the passwords

### Getting the passwords
```
gpg --full-generate-key
gpg --armor --export <key-id>

# In terraform
pgp_key = <<EOF
-----BEGIN PGP PUBLIC KEY BLOCK-----
...
-----END PGP PUBLIC KEY BLOCK-----
EOF

terraform output -json user_passwords > passwords.json
```
