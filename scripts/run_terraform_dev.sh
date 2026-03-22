#!/usr/bin/env bash

# Note: Ansible will authenticate later via the local 1Password SSH agent.

# Run Terraform with HCLOUD_TOKEN and TF_VAR_ssh_public_key injected from 1Password via .env file
# We specify the account explicitly to avoid ambiguity across multiple signed-in accounts
op run --account my.1password.com --env-file .env -- terraform apply
