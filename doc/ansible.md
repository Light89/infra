# Ansible Konfigurations-Dokumentation

Diese Dokumentation beschreibt die automatisierten Konfigurationsschritte, die via Ansible auf den Zielsystemen durchgeführt werden. Alle Rollen sind **100% idempotent** ausgelegt – sie können beliebig oft ausgeführt werden, ohne das System in einen inkonsistenten Zustand zu bringen.

## 1. Playbook-Ablauf

Das Haupt-Playbook (`site.yml`) ist modular aufgebaut und wendet verschiedene Rollen nacheinander an, um die gewünschte Zielkonfiguration zu erreichen.

```mermaid
sequenceDiagram
    participant Admin as Admin / CI
    participant Playbook as site.yml
    participant Common as Rolle: common
    participant Sec as Rolle: security_baseline
    participant Docker as Rolle: docker_host
    participant VM as Ziel-Server

    Admin->>Playbook: ansible-playbook run
    
    rect rgb(30, 41, 59)
    Note over Playbook,Common: Phase 1: Basis-System
    Playbook->>Common: Anwenden
    Common->>VM: Timezone & Logging
    end
    
    rect rgb(51, 65, 85)
    Note over Playbook,Sec: Phase 2: Härtung
    Playbook->>Sec: Anwenden
    Sec->>VM: SSH-Hardening
    end
    
    rect rgb(15, 23, 42)
    Note over Playbook,Docker: Phase 3: Applikations-Ready
    Playbook->>Docker: Anwenden
    Docker->>VM: Docker Engine & Compose
    end

    Playbook-->>Admin: Konfiguration abgeschlossen
```

---

## 2. Rolle: common (Basis-Konfiguration)

Die Rolle `common` stellt sicher, dass grundlegende Systemparameter auf allen Hosts identisch gesetzt sind.

### Aufgaben
1. **Timezone**: Die Systemzeit wird einheitlich auf **UTC** gesetzt, um Log-Analysen über verschiedene Zeitzonen hinweg zu vereinfachen.
2. **Journald-Optimierung**:
   - `SystemMaxUse=500M`: Begrenzt den Speicherplatz der Systemd-Logs auf 500 MB.
   - `MaxRetentionSec=1month`: Logs werden maximal einen Monat aufbewahrt.
   - Dies verhindert, dass die Festplatte durch ausufernde Log-Dateien vollgestillt wird.

---

## 3. Rolle: security_baseline (System-Härtung)

Diese Rolle implementiert grundlegende Sicherheitsmaßnahmen, um den SSH-Zugang abzusichern.

### Maßnahmen
1. **Password Authentication**: Deaktiviert den passwortbasierten Login (`PasswordAuthentication no`). Zugriff ist nur noch via SSH-Key möglich.
2. **Root Login**: Verhindert den direkten Root-Login via Passwort (`PermitRootLogin prohibit-password`). Dies zwingt Angreifer dazu, einen existierenden User-Account zu kennen oder Key-basierte Authentifizierung zu nutzen.

Diese Änderungen werden durch einen automatischen Reload des SSH-Dienstes sofort wirksam.

---

## 4. Rolle: docker_host (Applikations-Laufzeit)

Diese Rolle installiert die Docker Engine und alle notwendigen Komponenten für den Betrieb von Container-basierten Workloads.

### Aufgaben
1. **Dependencies**: Installation von `apt-transport-https`, `ca-certificates`, `curl`, `gnupg` und `lsb-release`.
2. **Repository**: Hinzufügen des offiziellen GPG-Keys und des Docker-Repositories für Debian (stable).
3. **Docker Installation**:
   - `docker-ce`: Docker Engine.
   - `docker-ce-cli`: CLI-Tools.
   - `containerd.io`: Container-Laufzeit.
   - `docker-compose-plugin`: Docker Compose (V2) Integration.
4. **Benutzer-Berechtigungen**: Der `ansible` User wird zur `docker` Gruppe hinzugefügt, um Docker-Befehle ohne `sudo` ausführen zu können (erleichtert die CI/CD-Automatisierung).
