# Code:You DevOps Provision User Accounts

NOTES:
- Need to have the csv file, by default there are no column names, manually added this in
- 


EXPECTED WORKFLOW:
1. Get the roster of students
2. Make sure the columns are (name, email, class) along with the header
3. Paste in the csv file content as a github secret in the repository
4. Run the Github Actions workflow called Provision New Students
5. viola