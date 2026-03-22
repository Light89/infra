#!/usr/bin/env bash

# Note: Ansible will authenticate later via the local 1Password SSH agent.

# Run Terraform with HCLOUD_TOKEN and TF_VAR_ssh_public_key injected from 1Password via .env file
# Ensure your .env file contains the op:// references before running this script
op run --env-file .env -- terraform apply
