# Terraform Infrastruktur-Dokumentation

Diese Dokumentation beschreibt die durch Terraform verwalteten Ressourcen, ihre Konfiguration und die zugrunde liegende Architektur. Das Ziel ist eine reproduzierbare, sichere und performante Infrastruktur auf Basis der Hetzner Cloud (HCloud).

## 1. Infrastruktur-Übersicht

Die Infrastruktur folgt einem modularen Ansatz, bei dem Netzwerk, Firewall und Compute-Instanzen (Server) getrennt voneinander definiert und miteinander verknüpft sind.

```mermaid
graph TD
    subgraph "Hetzner Cloud (nbg1)"
        direction TB
        Server["hcloud_server (dev-docker-01)"]
        Firewall["hcloud_firewall (dev-default-fw)"]
        Network["hcloud_network (dev-net)"]
        Subnet["hcloud_network_subnet"]
    end

    subgraph "State Management"
        S3["Hetzner Object Storage (S3)"]
    end

    Admin["Admin (deploy_mvp.sh)"] -.->|op run| TF["Terraform CLI"]
    TF -->|State| S3
    TF -->|Manage| Server
    TF -->|Manage| Firewall
    TF -->|Manage| Network
    
    Server --- Network
    Network --- Subnet
    Server --- Firewall
```

## 2. Remote State (S3 Backend)

Um Konsistenz in Team-Umgebungen zu gewährleisten und den Infrastruktur-Status sicher zu speichern, nutzt dieses Projekt ein S3-kompatibles Backend auf dem **Hetzner Object Storage**.

- **Bucket**: `ef-infra`
- **Key**: `dev/terraform.tfstate`
- **Endpoint**: `https://fsn1.your-objectstorage.com`

### Besonderheiten
- **Sicherheit**: Die Authentifizierung erfolgt ausschließlich über 1Password (`op run`), wodurch keine AWS-Keys lokal gespeichert werden müssen.
- **Konfiguration**: Aufgrund der Nutzung von Hetzner S3 (nicht AWS) sind diverse Validierungen deaktiviert (`skip_region_validation`, `skip_credentials_validation`, etc.), um Kompatibilität sicherzustellen.
