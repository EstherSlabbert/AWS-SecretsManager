#!/bin/bash
# set up aws cli
sudo apt update
sudo apt install awscli
aws configure

# set up gnupg if not already installed
sudo apt update
sudo apt install gnupg

# Command to create a Secret from a GPG Key
# Replace <key-id> with the ID or fingerprint of your GPG key.
# This command exports the secret key using the gpg command and creates a secret named "MyGPGKey" in AWS Secrets Manager.
aws secretsmanager create-secret --name MyGPGKey --secret-string "$(gpg --export-secret-keys --armor <key-id>)"

# IAM Policy for EC2 to access secret (replace arn):
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": "secretsmanager:GetSecretValue",
#       "Resource": "arn:aws:secretsmanager:eu-west-1:123456789012:secret:MyGPGKey-*"
#     }
#   ]
# }

# Command to retrieve the GPG private key from AWS Secrets Manager
aws secretsmanager get-secret-value --secret-id MyGPGKey --query SecretString --output text | gpg --import
# now use the key to encrypt/decrypt.
