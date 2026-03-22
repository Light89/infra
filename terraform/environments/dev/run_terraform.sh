#!/usr/bin/env bash

# Export SSH Key from 1Password
# This will be injected into Terraform via the TF_VAR_ssh_public_key environment variable
export TF_VAR_ssh_public_key=$(op read "op://Vault/SSH_Key/public_key")

# Note: Ansible will authenticate later via the local 1Password SSH agent.

# Run Terraform with HCLOUD_TOKEN injected from 1Password via .env file
op run --env-file .env -- terraform apply
