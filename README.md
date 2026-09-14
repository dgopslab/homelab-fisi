# Homelab FISI

Dieses Repository dokumentiert mein Homelab während der Umschulung zum Fachinformatiker für Systemintegration.

Ich nutze die Umgebung, um Themen aus Linux, Windows Server, Virtualisierung und Netzwerken praktisch nachzuvollziehen. Die Systeme laufen als virtuelle Maschinen unter KVM/QEMU und libvirt.

## Aktueller Aufbau

| System | Aufgabe |
|---|---|
| Pop!_OS 22.04 LTS | Homelab-Host mit KVM/QEMU und libvirt |
| `DC01` | Windows Server 2025 mit Active Directory und AD-integriertem DNS |
| `srv-linux01` | Ubuntu Server 24.04.4 LTS, SSH-Ziel und Mitglied der AD-Domäne |

Die beiden Server befinden sich im libvirt-NAT-Netz `192.168.122.0/24`.

## Abgeschlossenes Teilprojekt: Active Directory und Linux

**Technischer Projektumfang: abgeschlossen**

Ziel des Teilprojekts war eine zentrale Identitätsverwaltung mit Active Directory und eine gruppenbasierte Zugriffssteuerung für einen Linux-Server.

Dafür wurden:

- die AD-Domäne `ad.dgopslab.test` eingerichtet,
- Benutzer, Gruppen und Organisationseinheiten im Active Directory angelegt,
- `srv-linux01` über Kerberos, `realmd` und SSSD in die Domäne aufgenommen,
- AD-Anmeldungen auf Mitglieder der Gruppe `Linux-Zugang` beschränkt und
- ein lokaler administrativer SSH-Rückfallzugang erhalten.

Ein berechtigter AD-Testbenutzer konnte sich anmelden. Ein nicht berechtigter AD-Testbenutzer wurde abgewiesen. Nach einem Neustart blieben Domänenmitgliedschaft, Benutzerauflösung und Zugriffskontrolle erhalten.

Auftretende Kerberos-Probleme wurden schrittweise eingegrenzt und nach den jeweiligen Korrekturen erneut geprüft. Die vollständige Fehleranalyse und die technischen Tests stehen in der Projektseite:

[Active Directory und Linux integrieren](docs/05-active-directory-linux-integration.md)

## Weitere Dokumentation

- [Host-Baseline](docs/01-host-baseline.md)
- [srv-linux01](docs/02-srv-linux01.md)
- [SSH-Zugriff](docs/03-ssh.md)
- [IPv4-Paketweg im libvirt-NAT-Netz](docs/04-network-path-libvirt-nat.md)
- [Fehlersuche bei Home-Verzeichnisrechten](docs/troubleshooting/01-home-directory-permissions.md)
- [Glossar](glossar.md)

## Nächste Schritte

Das Homelab wird unabhängig vom abgeschlossenen AD-/Linux-Teilprojekt weiter ausgebaut. Vorgesehen sind:

- die vorbereitete LVM-Erweiterung auf `srv-linux01`,
- bewusst durchgeführte und dokumentierte Ubuntu-Updates und
- später eine stärkere Trennung der virtuellen Netze.

## Sicherheit

Passwörter, private Schlüssel, Keytab-Inhalte, Tokens und andere Zugangsdaten werden nicht im Repository gespeichert.
