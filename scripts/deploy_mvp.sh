#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Configuration
ENV_DIR="$BASE_DIR/terraform/environments/dev"
INVENTORY_FILE="$BASE_DIR/ansible/inventory/dev/hosts.ini"
PLAYBOOK_FILE="$BASE_DIR/ansible/playbooks/site.yml"

echo "Step 1: Provisioning infrastructure with Terraform..."
cd "$ENV_DIR"
# Assuming op is available as per the environment
op run --account my.1password.com --env-file .env -- terraform apply -auto-approve

echo "Step 2: Extracting server IPs..."
SERVER_IPS_JSON=$(op run --account my.1password.com --env-file .env -- terraform output -json server_ips)

if [ -z "$SERVER_IPS_JSON" ] || [ "$SERVER_IPS_JSON" == "null" ]; then
    echo "Error: Could not retrieve server IPs from Terraform output."
    exit 1
fi

echo "Step 3: Ansible Inventory (Dynamic)..."
# Die manuelle Pflege von hosts.ini entfällt, da wir nun das hetzner.hcloud Plugin nutzen.
# Das Plugin erkennt den Server automatisch anhand seiner Labels.

echo "Step 4: Waiting for cloud-init and SSH..."
echo "$SERVER_IPS_JSON" | jq -r '.[]' | while read -r ip; do
    if [ -n "$ip" ]; then
        echo "Waiting for $ip to become reachable..."
        # Simple wait loop
        until nc -zvw1 "$ip" 22; do
          sleep 5
        done
        echo "[OK] $ip is ready!"
    fi
done

echo "Step 5: Applying Ansible playbooks..."
cd "$BASE_DIR"

# Fetch private key securely for Ansible
PRIVATE_KEY_FILE=$(mktemp)
op read "op://kox2l2elvuwbmiszxmgo7ojxja/4o7yybaviycv7tbgbby2gmze5a/private key" --account my.1password.com > "$PRIVATE_KEY_FILE"
chmod 600 "$PRIVATE_KEY_FILE"

# Disable SSH agent to prevent 'communication with agent failed' errors
# Wir nutzen nun das dynamische Inventar hcloud.yml
env SSH_AUTH_SOCK="" op run --account my.1password.com --env-file "$ENV_DIR/.env" -- ansible-playbook -i ansible/inventory/dev/hcloud.yml ansible/playbooks/site.yml --user ansible --private-key "$PRIVATE_KEY_FILE"


# Clean up
rm -f "$PRIVATE_KEY_FILE"

echo "Deployment complete! All servers are provisioned and configured."
