# Server-Übersicht (Inventory)

Diese Übersicht listet alle aktuell vom Repository verwalteten Server auf. Die Provisionierung erfolgt via Terraform, die Konfiguration via Ansible.

## 1. Aktive Hosts

| Hostname | Rolle | Typ | Standort | IP (Ext.) | Zweck |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `dev-docker-01` | `docker-host` | CX23 | nbg1 | `178.104.66.111` | Haupt-Docker Host für Dev-Workloads |
| `gitlab` | `utility` | CX23 | fsn1 | `116.202.15.80` | Zentrale GitLab-Instanz (Infrastruktur) |

## 2. Rollen-Definitionen

- **`docker-host`**: Server mit installierter Docker Engine, bereit für Container-Deployments.
- **`utility`**: Infrastruktur-Server für begleitende Dienste (GitLab, Monitoring, Backups).
- **`base`**: Minimal-System ohne spezialisierte Software (nur Härtung & Basics).

## 3. Verwaltung

- **Terraform**: Die Definition der Server erfolgt in [`terraform/environments/dev/variables.tf`](file:///Users/josephinelange/infra/terraform/environments/dev/variables.tf) über die Variable `servers`.
- **Ansible**: Der Zugriff erfolgt über das dynamische Inventar ([`hcloud.yml`](file:///Users/josephinelange/infra/ansible/inventory/dev/hcloud.yml)), welches die Server anhand ihrer Labels (`role`) gruppiert.

---
*Zuletzt aktualisiert: 2026-03-22*
