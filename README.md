# Hetzner Cloud MVP Infrastructure

Ein lokales Minimum Viable Product (MVP) Setup für die automatisierte Bereitstellung und Konfiguration von Servern in der Hetzner Cloud (hcloud).

## Architektur-Prinzipien

Dieses Repository folgt einer strikten Trennung der Zuständigkeiten:

1. **Terraform**: Verantwortlich für die Erstellung der Cloud-Ressourcen (Netzwerke, Firewalls, Server-Instanzen). Der Status wird sicher in einem externen **S3-kompatiblen Object Storage Backend** verwaltet.
2. **Cloud-init**: Zieht das System beim ersten Boot hoch (Bootstrap). Es legt den dedizierten `ansible`-User an, hinterlegt den SSH-Key (ohne Passwort-Login) und installiert Minimalvoraussetzungen wie Python 3.
3. **Ansible**: Übernimmt die eigentliche fachliche Provisionierung idempotent (z. B. Sicherheitsrichtlinien, Docker-Installation, System-Härtung).

### Das MVP Setup
Aktuell provisioniert Terraform folgendes Setup:
- `dev-net` (Privates Netzwerk `10.1.0.0/16`)
- `dev-default-fw` (Erlaubt SSH, ICMP, etc.)
- `dev-docker-01` (Eine Debian 13 (Trixie) VM)

## Voraussetzungen

* [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.60)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [1Password CLI (op)](https://developer.1password.com/docs/cli) (Zwingend für sicheres Secrets-Management)

## Geheimnisverwaltung mit 1Password (Local-First)

Um hartkodierte Secrets im Quellcode zu vermeiden, nutzt dieses Setup konsequent die 1Password CLI. **Terraform und Ansible haben zu keinem Zeitpunkt statische Secrets auf der Festplatte.**

### 1. Umgebungsvariablen für Terraform
Bevor Terraform ausgeführt wird, zieht `op run` die benötigten Referenzen (Hetzner API Token, S3 Credentials für das State-Backend, SSH Public Key) aus der lokalen `.env` Datei (`terraform/environments/dev/.env`):

```env
# Authentifizierung
HCLOUD_TOKEN="op://Vault/Hetzner_Token/credential"
TF_VAR_ssh_public_key="op://Vault/SSH_Key/public_key"

# S3 State Backend Credentials
AWS_ACCESS_KEY_ID="op://Vault/S3_Access_Key/credential"
AWS_SECRET_ACCESS_KEY="op://Vault/S3_Secret_Key/credential"
```

### 2. SSH Private Key Injection für Ansible
Anstatt das SSH-Passwort in Ansible abzulegen oder sich auf einen fehleranfälligen lokalen SSH-Agenten zu verlassen, wird bei jedem Lauf der private SSH-Schlüssel dynamisch per UUID über `op read` bezogen. Die Kommunikation mit dem SSH-Agent wird explizit deaktiviert (`env SSH_AUTH_SOCK=""`), um Verbindungsabbrüche in automatisierten Skripten zu verhindern.

## Automatisierter Deployment Workflow

Ein zentrales Bash-Skript bündelt den gesamten Deployment-Prozess von der Infrastruktur-Veränderung bis hin zur Ansible-Konfiguration.

### Erste Schritte (Deployment)

Führe einfach das Deployment-Skript aus:

```bash
cd scripts
./deploy_mvp.sh
```

**Was macht das Skript?**
1. **Provision Infrastructure**: Führt `terraform apply` über den 1Password-Kontext (`op run`) aus. Das schließt auch die S3 Backend-Authentifizierung mit ein.
2. **Extract IP**: Bezieht die neu provisionierte Server-IP über die Terraform Outputs.
3. **Update Inventory**: Aktualisiert automatisch das Ansible Inventory (`ansible/inventory/dev/hosts.ini`).
4. **Wait for Cloud-Init**: Wartet, bis die VM hochgefahren ist und Port 22 per Netcat erreichbar ist.
5. **Apply Ansible**: Extrahiert temporär den privaten SSH-Schlüssel für die Verbindung und wendet das Haupt-Playbook (`site.yml`) auf den Host `dev-docker-01` an.

## Ordnerstruktur

```text
.
├── README.md
├── scripts
│   └── deploy_mvp.sh              # 🚀 Zentraler Entrypoint fürs Deployment
├── ansible
│   ├── ansible.cfg                # Ansible Basiskonfiguration
│   ├── inventory/dev/hosts.ini    # Dynamisch generiertes Inventory
│   ├── playbooks
│   │   └── site.yml               # Haupt-Playbook für Rollenzuweisung
│   └── roles                      
│       ├── common                 # Setup Base Tools
│       ├── security_baseline      # System Härtung
│       └── docker_host            # Docker Installation (Debian 13 kompatibel, GPG Keyrings via get_url)
└── terraform
    ├── environments/dev           # Dev-Umgebung (Live-Konfiguration & Variablen)
    │   ├── backend.tf             # S3 Object Storage Definition
    │   └── main.tf                # MVP Ressourcen
    └── modules                    # Wiederverwendbare Terraform-Module
        ├── firewall               # Cloud-Firewall (Port 22, ICMP)
        ├── network                # Privates Hetzner-Netzwerk
        └── server                 # Debian 13 VM inkl. cloud-init Template
```
