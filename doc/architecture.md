# Deployment Architecture (`deploy_mvp.sh`)

This document outlines the exact sequence of systems integration that occurs automatically when `./scripts/deploy_mvp.sh` is executed. The script serves as the bridge between declarative infrastructure (Terraform), secure local-first secrets (1Password), and imperative configuration management (Ansible).

## Execution Sequence

```mermaid
sequenceDiagram
    autonumber
    
    actor Admin
    participant Script as deploy_mvp.sh
    participant 1Pwd as 1Password CLI
    participant TF as Terraform
    participant S3 as S3 State Backend
    participant HCloud as Hetzner API
    participant Ansible as Ansible
    participant VM as dev-docker-01

    Admin->>Script: Run ./deploy_mvp.sh

    rect rgb(30, 41, 59)
    Note over Script,HCloud: Step 1: Provision Infrastructure
    Script->>1Pwd: op run (read .env)
    1Pwd-->>Script: Inject Secrets (HCLOUD_TOKEN, AWS_*)
    Script->>TF: terraform apply -auto-approve
    TF<->>S3: Authenticate & Lock State (via op run)
    TF->>HCloud: Provision Network, FW, VM
    HCloud-->>TF: Success (VM booted)
    TF<->>S3: Update State & Unlock
    TF-->>Script: Apply Complete
    end

    rect rgb(51, 65, 85)
    Note over Script,TF: Step 2 & 3: IP Sync & Inventory Update
    Script->>TF: op run -- terraform output server_ip
    TF-->>Script: 178.x.x.x
    Script->>Script: sed: Update hosts.ini with IP
    end

    rect rgb(71, 85, 105)
    Note over Script,VM: Step 4: Boot & Network Validation
    loop Check Port 22 availability via TCP
        Script->>VM: nc -zvw1 178.x.x.x 22
        VM-->>Script: Connection Refused
        Note over Script: sleep 5
        VM-->>Script: Connection Succeeded (Cloud-init finished)
    end
    end

    rect rgb(15, 23, 42)
    Note over Script,VM: Step 5: Configuration Management
    Script->>1Pwd: op read (Fetch Private SSH Key via UUID)
    1Pwd-->>Script: Clean Private Key -> /tmp/file
    Note over Script,Ansible: SSH Agent Bypass (env SSH_AUTH_SOCK="")
    Script->>Ansible: ansible-playbook --private-key /tmp/file
    Ansible->>VM: Connect over SSH (User: ansible)
    VM-->>Ansible: Authenticated!
    Ansible->>VM: Apply roles: common, security, docker
    VM-->>Ansible: Done
    Ansible-->>Script: Playbook Complete
    end

    Script->>Script: rm -f /tmp/file (Clean up Key)
    Script-->>Admin: Deployment complete! Server IP: 178.x.x.x
```

## Architectural Decisions & Considerations

### 1. 1Password "Local-First" Injection (`op run`)
Terraform relies on environment variables for API tokens (`HCLOUD_TOKEN`) and S3 backend logic (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`). Instead of storing these anywhere plaintext, the script invokes Terraform through `op run`. 1Password intercepts the execution, resolves `op://...` references from the local `.env` file, injects the real values securely strictly into Terraform's process memory, and cleans up immediately after termination.

### 2. S3 State Backend Authentication
To prevent concurrency issues and ensure state persistence outside the local repository, moving to an S3 backend was critical. Because the `terraform output` command *also* needs to communicate with the S3 backend via the exact same AWS credentials, Step 2 is prefixed with `op run`, resolving the otherwise fatal `"No valid credential sources found"` error.

### 3. SSH Agent Bypass (`env SSH_AUTH_SOCK=""`)
Automated playbooks shouldn't randomly halt on biometric 1Password prompts or fail due to `communication with agent failed` errors. By explicitly bypassing the system's SSH Agent (`SSH_AUTH_SOCK=""`) and utilizing Python's `getopt`/Ansible's explicitly defined `--private-key` (extracted dynamically seconds before execution via `op read` using strong UUID references), predictability and automation reliability are guaranteed.
