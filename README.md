# Hetzner Cloud MVP Infrastructure

Ein lokales Minimum Viable Product (MVP) Setup für die Provisionierung und Konfiguration von Servern in der Hetzner Cloud (hcloud).

## Architektur-Prinzipien

Dieses Repository folgt einer strikten Trennung der Zuständigkeiten:

1. **Terraform**: Verantwortlich für die Erstellung der Cloud-Ressourcen (Netzwerke, Firewalls, Server-Instanzen).
2. **Cloud-init**: Macht die Server beim ersten Boot nutzbar (Bootstrap: Admin-User anlegen, SSH-Key hinterlegen, Basis-Pakete installieren). Es enthält **keine** Anwendungs- oder Fachlogik.
3. **Ansible**: Bringt die Server idempotent in den finalen gewünschten Zustand (z.B. SSH-Härtung, Docker-Installation) und verwaltet fortan das Konfigurationsmanagement.

## Voraussetzungen

* [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.60)
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
* [1Password CLI (op)](https://developer.1password.com/docs/cli) für sicheres Secrets-Management

## Geheimnisverwaltung mit 1Password (Local-First)

Um hartkodierte Secrets im Quellcode zu vermeiden, nutzt dieses Setup die 1Password CLI zur Injektion von Umgebungsvariablen zur Laufzeit.

### 1. Terraform Ausführung
Bevor Terraform ausgeführt wird, muss das `HCLOUD_TOKEN` als Umgebungsvariable (z.B. über eine `.env` Datei) sowie der SSH-Key als `TF_VAR_ssh_public_key` bereitgestellt werden.

Ein beispielhafter Workflow ist im Skript `terraform/environments/dev/run_terraform.sh` dokumentiert:

```bash
# SSH-Key aus 1Password exportieren und in Variable injizieren
export TF_VAR_ssh_public_key=$(op read "op://Vault/SSH_Key/public_key")

# Terraform mit dem HCLOUD_TOKEN (via .env) über 1Password ausführen
op run --env-file .env -- terraform apply
```

### 2. Ansible Ausführung
Ansible benötigt das Passwort für den SSH-Key nicht in den Konfigurationsdateien. Die Authentifizierung erfolgt über den lokalen **1Password SSH-Agenten**. Stelle sicher, dass der 1Password SSH-Agent läuft und dein Key dort hinterlegt ist.

## Ordnerstruktur

```text
.
├── README.md
├── ansible
│   ├── ansible.cfg                # Ansible Basiskonfiguration
│   ├── inventory/dev/hosts.ini    # Statisches Inventory der Dev-Umgebung
│   ├── playbooks
│   │   └── site.yml               # Haupt-Playbook für Rollenzuweisung
│   └── roles                      # Ansible Rollen (common, security_baseline, docker_host)
└── terraform
    ├── environments/dev           # Dev-Umgebung (Live-Konfiguration & Variablen)
    └── modules                    # Wiederverwendbare Terraform-Module
        ├── firewall               # Cloud-Firewall (Port 22, ICMP)
        ├── network                # Privates Hetzner-Netzwerk
        └── server                 # Debian 13 VM inkl. cloud-init Template
```

## Erste Schritte Starten

1. Navigiere in das `terraform/environments/dev` Verzeichnis.
2. Initialisiere Terraform:
   ```bash
   terraform init
   ```
3. Setze deine Secrets über 1Password und führe das Setup aus:
   ```bash
   ./run_terraform.sh
   # (Dieses Skript führt im Beispiel 'terraform apply' aus)
   ```
4. IP-Adresse aus dem Output (`server_ip`) im Ansible Inventory (`ansible/inventory/dev/hosts.ini`) eintragen.
5. Führe Ansible aus, um den Server final zu konfigurieren:
   ```bash
   cd ../../../ansible
   ansible-playbook playbooks/site.yml
   ```
