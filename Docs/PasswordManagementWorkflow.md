# PGP Key Management and Integration with Terraform

This document outlines the process of generating a PGP key, securely storing it in AWS Secrets Manager, and dynamically retrieving it in Terraform to encrypt sensitive information such as user passwords.

---

## Overview

This approach ensures:
1. **Secure Key Management:** The PGP key is securely stored in AWS Secrets Manager, while the private key remains securely managed by the administrator.
2. **Dynamic Key Retrieval:** Terraform dynamically retrieves the PGP public key from Secrets Manager, enabling password encryption during resource creation.
3. **Cost-Effectiveness:** Using a single PGP key for all users reduces operational costs and simplifies key management.

---

## Steps to Implement

### 1. Generate the PGP Key

1. **Generate the Key Pair**:
   Use `gpg` to create a new PGP key pair:
   ```bash
   gpg --gen-key
   ```
   Follow the prompts to set:
   - Name and email
   - Key type and size (default is recommended)
   - Expiration (optional)

2. **Export the Public Key**:
   ```bash
   gpg --armor --export "your-key-id" > public_key.asc
   ```

3. **Export the Private Key (for secure storage)**:
   ```bash
   gpg --armor --export-secret-keys "your-key-id" > private_key.asc
   ```

   **Important:** Store the private key securely (e.g., hardware security module, encrypted file storage).

---

### 2. Store the Public Key in AWS Secrets Manager

1. **Store the Public Key**:
   Use the AWS CLI to store the public key in Secrets Manager:
   ```bash
   aws secretsmanager create-secret \
     --name PGPPublicKey \
     --description "PGP Public Key for encrypting student passwords" \
     --secret-string file://public_key.asc
   ```

2. **Verify the Secret**:
   Confirm that the secret was created:
   ```bash
   aws secretsmanager describe-secret --secret-id PGPPublicKey
   ```

---

### 3. Configure Terraform to Retrieve the Key

Use Terraform to dynamically retrieve the PGP public key and use it to encrypt user passwords.

#### Example Terraform Configuration

```hcl
# Retrieve the PGP key from Secrets Manager
data "aws_secretsmanager_secret" "pgp_public_key" {
  name = "PGPPublicKey"
}

data "aws_secretsmanager_secret_version" "pgp_public_key_version" {
  secret_id = data.aws_secretsmanager_secret.pgp_public_key.id
}

# Generate random passwords for each student
resource "random_password" "iam_user_passwords" {
  for_each         = local.students
  length           = 16
  special          = true
  override_special = "_%@"
}

# Create IAM login profiles with encrypted passwords
resource "aws_iam_user_login_profile" "student_user_login" {
  for_each                = local.students
  user                    = aws_iam_user.student_user[each.key].name
  password                = random_password.iam_user_passwords[each.key].result
  password_reset_required = true
  pgp_key                 = data.aws_secretsmanager_secret_version.pgp_public_key_version.secret_string
}

# Output encrypted passwords for manual decryption
output "encrypted_passwords" {
  value = {
    for key, login in aws_iam_user_login_profile.student_user_login : key => login.encrypted_password
  }
  sensitive = true
}
```

---

### 4. Decrypting Passwords

1. Retrieve the encrypted passwords using Terraform:
   ```bash
   terraform output -json encrypted_passwords > encrypted_passwords.json
   ```

2. Decrypt passwords using your private PGP key:
   ```bash
   echo "ENCRYPTED_PASSWORD" | base64 -d | gpg --decrypt
   ```

   Alternatively, use a script to batch-decrypt all passwords.

---

### 5. Best Practices

1. **Secure Private Key Storage**:
   - Store the private key securely, such as in a hardware security module (HSM) or encrypted vault.

2. **Enable Access Control**:
   - Restrict access to the PGP key in AWS Secrets Manager using fine-grained IAM policies.

3. **Audit Key Usage**:
   - Use AWS CloudTrail to monitor access to the PGP key in Secrets Manager.

4. **Rotate Keys Periodically**:
   - Regularly rotate the PGP key and update the corresponding secret in AWS Secrets Manager.

---

### Future Enhancements

- **Automate Key Rotation:** Implement a Lambda function to automate PGP key rotation and update Secrets Manager.
- **Notification System:** Use an email or messaging service to securely distribute initial login credentials to users.

---

This workflow ensures secure password encryption and key management, aligning with AWS best practices for sensitive data handling.
