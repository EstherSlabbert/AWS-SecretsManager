# AWS Secrets Manager

[AWS Secrets Manager](https://aws.amazon.com/secrets-manager/)

- [AWS Secrets Manager](#aws-secrets-manager)
  - [What is it?](#what-is-it)
  - [How does AWS Secrets Manager keep my secrets secure?](#how-does-aws-secrets-manager-keep-my-secrets-secure)
  - [How does AWS Secrets Manager encrypt my secrets?](#how-does-aws-secrets-manager-encrypt-my-secrets)
  - [Why use it?](#why-use-it)
    - [Benefits](#benefits)
    - [Drawbacks](#drawbacks)
  - [How to use it?](#how-to-use-it)
  - [Cost](#cost)

## What is it?

AWS Secrets Manager is a **secrets management service** that helps you protect access to your applications, services, and IT resources. This service enables you to easily rotate, manage, and retrieve database credentials, API keys, and other secrets throughout their lifecycle. Using Secrets Manager, you can **secure and manage secrets used to access resources** in the AWS Cloud, on third-party services, and on-premises.

[What is Secrets Manager?](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html)

## How does AWS Secrets Manager keep my secrets secure?

AWS Secrets Manager **encrypts at rest** using encryption keys that you own and store in AWS Key Management Service (KMS). You can **control access to the secret using AWS Identity and Access Management (IAM) policies**. When you **retrieve a secret**, Secrets Manager **decrypts the secret and transmits it securely over TLS to your local environment**. By default, Secrets Manager does not write or cache the secret to persistent storage.

- SM encrypts data (stored as plain text or JSON) using KMS (may use default CMK or customer-created CMK)
- Attach an IAM policy (granularly) to your application for read-only permissions to your secret
- Only accepts requests from host using open standard Transport Layer Security (TLS) and perfect forward secrecy (When you retrieve a secret through an API call, Secrets Manager decrypts the secret and transmits it securely over TLS to your local environment. By default, Secrets Manager does not write or cache the secret to persistent storage.)
- AWS gives sample code for different programming languages to access the secret.
- Ensures in transit security
- Can configure to automatically rotate secrets using custom Lambda functions if not for AWS data service (good practice)

## How does AWS Secrets Manager encrypt my secrets?

AWS Secrets Manager uses [**envelope encryption (AES-256 encryption algorithm)**](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping) to encrypt your **secrets in AWS Key Management Service (KMS)**.
When you first use Secrets Manager, you can specify the AWS KMS keys to encrypt secrets. If you do not provide a KMS key, Secrets Manager creates AWS KMS default keys for your account automatically. When a secret is stored, Secrets Manager requests a plaintext and an encrypted data key from KMS. Secrets Manager uses the plaintext data key to encrypt the secret in memory. AWS **Secrets Manager stores and maintains the encrypted secret and encrypted data key**. When a secret is retrieved, Secrets Manager decrypts the data key (using the AWS KMS default keys) and uses the plaintext data key to decrypt the secret. The data key is stored encrypted and is never written to disk in plaintext. Also, Secrets Manager does not write or cache the plaintext secret to persistent storage.

[More on Encryption and Decryption with Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/security-encryption.html)

## Why use it?

AWS Secrets Manager protects access to your applications, services, and IT resources, without the upfront investment and on-going maintenance costs of operating your own infrastructure.

Secrets Manager is for IT administrators looking for a secure and scalable method to store and manage secrets. Security administrators responsible for meeting regulatory and compliance requirements can use Secrets Manager to monitor secrets and rotate secrets without a risk of impacting applications. Developers who want to replace hardcoded secrets in their applications can retrieve secrets programmatically from Secrets Manager.

### Benefits

- Secrets are generally cache-able for use within applications (reducing cost by not requesting each time)
- Centralizes Secrets storage
- Encrypts data
- Managed by IAM (granular access controls) [IAM policy example found in the links on this page](https://docs.aws.amazon.com/secretsmanager/latest/userguide/infrastructure-security.html)
- Utilizes MFA for AWS
- Access can be monitored using CloudWatch
- Can control lifecycle, including rotation, of secrets if necessary
- Can use Terraform to upload secrets (automate uploading multiple secrets) [Terraform: Secrets Manager Upload Secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret)
<!--
secrets.tfvars file:
```
secrets = [
  {
    name  = "secret1"
    value = "value1"
  },
  {
    name  = "secret2"
    value = "value2"
  },
  ...
]
```
Terraform automation script:
```hcl
provider "aws" {
  region = "us-west-2"  # Update with your desired AWS region
}

variable "secrets" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "List of secrets to upload"
}

resource "aws_secretsmanager_secret" "my_secret" {
  count = length(var.secrets)

  name = var.secrets[count.index].name
}

resource "aws_secretsmanager_secret_version" "my_secret_version" {
  count       = length(var.secrets)
  secret_id   = aws_secretsmanager_secret.my_secret[count.index].id
  secret_string = var.secrets[count.index].value
}
```
`terraform init`

`terraform apply -var-file="secrets.tfvars"`

OR

Secrets file:
```json
[
  {
    "name": "secret1",
    "value": "value1"
  },
  {
    "name": "secret2",
    "value": "value2"
  },
  ...
]
```
AWS CLI script:
```bash
#!/bin/bash

SECRETS_FILE="secrets.json"

# Read the secrets from the JSON file
secrets=$(cat "${SECRETS_FILE}")

# Loop through each secret and upload to Secrets Manager
for row in $(echo "${secrets}" | jq -c '.[]'); do
  name=$(echo "${row}" | jq -r '.name')
  value=$(echo "${row}" | jq -r '.value')

  aws secretsmanager create-secret --name "${name}" --secret-string "${value}"
done
```
-->
- Can use Terraform to put secret policy in place [Terraform: Secrets Manager Set Secret IAM Policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_policy)
- Can use Terraform to access secrets stored by Secrets Manager [Terraform: Secrets Manager Retrieve Secret](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret)
<!--
```hcl
provider "aws" {
  region = "us-west-2"  # Update with your desired AWS region
}

data "aws_secretsmanager_secret" "my_secret" {
  name = "my-secret"  # Update with the name of your secret
}

output "secret_value" {
  value = data.aws_secretsmanager_secret.my_secret.secret_string
}
```
-->

### Drawbacks

- Cost
- Must use policies to grant/deny granular permissions
- Must create/upload secrets one by one (AWS Secrets Manager does not provide a native capability to upload multiple secrets in a single operation. Each secret needs to be uploaded individually using the appropriate API or SDK calls. If you have multiple secrets that you want to upload to AWS Secrets Manager, you would need to write code or use automation tools to loop through your secrets and upload them one by one.)
- Probably need to update current coded secrets to retrieve them from Secrets Manager instead of current location

## How to use it?

To get started with AWS Secrets Manager:

1. Identify your secrets and locate where they are used in your applications.
2. Sign in to the AWS Management Console using your AWS credentials and navigate to the Secrets Manager console.
3. Use the Secrets Manager console to upload the secret you identified. Alternatively, you can use the AWS SDK or AWS CLI to upload a secret (once per secret). You can also write a script to upload multiple secrets.
4. If your secret is not in use yet, follow the instructions on the console to configure automatic rotation. If applications are using your secret, complete steps (5) and (6) before configuring automatic rotation.
5. If other users or applications need to retrieve the secret, write an IAM policy to grant permissions to the secret.
6. Update your applications to retrieve secrets from Secrets Manager.

## Cost

With Secrets Manager, you pay only for what you use, there is no minimum fee. At the end of the month, your credit card will automatically be charged for that month’s usage. You are charged for number of secrets you store and for API requests made to the service each month.

You can use the AWS managed key `aws/secretsmanager` that Secrets Manager creates to encrypt your secrets for free. If you create your own KMS keys to encrypt your secrets, AWS charges you at the current AWS KMS rate.

- 30 day free trial
- $0.40 per secret per month + $0.05 per 10,000 GetSecretValue API calls

---
Note: Each AWS KMS key that you create in AWS KMS costs $1/month (prorated hourly), but this is only if you use your own KMS keys.

---

[Secrets Manager Pricing](https://aws.amazon.com/secrets-manager/pricing/)
