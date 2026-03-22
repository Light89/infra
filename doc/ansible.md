# Ansible Konfigurations-Dokumentation

Diese Dokumentation beschreibt die automatisierten Konfigurationsschritte, die via Ansible auf den Zielsystemen durchgeführt werden. Alle Rollen sind **100% idempotent** ausgelegt – sie können beliebig oft ausgeführt werden, ohne das System in einen inkonsistenten Zustand zu bringen.

## 1. Playbook-Ablauf
...
## 2. Rolle: common (Basis-Konfiguration)
...
## 3. Rolle: security_baseline (System-Härtung)
...
## 4. Rolle: docker_host (Applikations-Laufzeit)
...
## 5. Rolle: utility_host (Infrastruktur-Dienste)

Die Rolle `utility_host` ist für Server vorgesehen, die administrative Hilfsaufgaben oder zentrale Infrastruktur-Dienste übernehmen (z.B. Bastion-Hosts, Monitoring-Einstiegspunkte oder Backup-Knoten).

### Aufgaben & Funktionen
1. **Rollen-Verifikation**: Ein Sicherheitscheck stellt sicher, dass die Rolle nur auf dafür vorgesehenen Hosts (Label `role: utility`) ausgeführt wird.
2. **System-Vorbereitung**: Optimierung des Systems für Hintergrund-Tasks und administrative Werkzeuge.
3. **Erweiterbarkeit**: Diese Rolle dient als Basis für zukünftige Dienste:
   - **Backup-Management**: Zentrale Steuerung von Datenbank-Dumps und Dateisicherungen.
   - **Monitoring-Aggregatoren**: Sammeln von Metriken der anderen Cluster-Knoten.
   - **CI/CD Runner**: Lokale Ausführung von Build-Prozessen.

---

## 6. Qualitätssicherung (Linting)

Um die Wartbarkeit und Sicherheit der Playbooks zu garantieren, wird `ansible-lint` eingesetzt.

- **Zweck**: Statische Analyse der YAML-Dateien auf Best Practices (z.B. korrekte Modul-Parameter, keine "naked" commands, sichere File-Berechtigungen).
- **IDE-Integration**: Der Pfad zum Executable (`/opt/homebrew/bin/ansible-lint`) kann direkt in der IDE hinterlegt werden, um Live-Feedback beim Editieren zu erhalten.
