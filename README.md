# Homelab FISI

Dieses Repository dokumentiert mein persönliches Homelab während meiner Umschulung zum **Fachinformatiker für Systemintegration**.

Ich nutze das Lab, um Themen aus der Umschulung praktisch nachzuvollziehen, Konfigurationen selbst auszuprobieren und auftretende Fehler systematisch zu untersuchen.

## Aktueller Aufbau

Das Homelab läuft derzeit auf meinem Desktop-PC unter **Pop!_OS 22.04 LTS**.

Für die Virtualisierung verwende ich:

* KVM/QEMU
* libvirt
* virt-manager und virsh
* das libvirt-Netzwerk `default` im NAT-Modus

Als erste Server-VM läuft:

`srv-linux01` – Ubuntu Server 24.04.4 LTS

Die VM befindet sich aktuell im virtuellen Netz `192.168.122.0/24` und erhält ihre Netzwerkkonfiguration per DHCP über libvirt.

Für den externen Zugriff auf den Homelab-Host verwende ich Tailscale.

## Bisher umgesetzt und untersucht

Im bisherigen Aufbau habe ich unter anderem:

* den Homelab-Host und seine Virtualisierungsumgebung überprüft
* eine Ubuntu-Server-VM mit KVM/QEMU und libvirt eingerichtet
* das virtuelle NAT-Netzwerk sowie Gateway, Routing und DNS-Verhalten untersucht
* die VM über SSH administriert
* ein eigenes Ed25519-Schlüsselpaar für das Homelab eingerichtet
* die SSH-Client-Konfiguration für `srv-linux01` eingerichtet und getestet
* Linux-Datei- und Verzeichnisrechte bei einer konkreten Berechtigungsstörung untersucht

Dabei dokumentiere ich möglichst nicht nur die verwendeten Befehle, sondern auch, was ich damit prüfe und wie ich das Ergebnis einordne.

## Dokumentation

### Aufbau und Systeme

* [`01-host-baseline.md`](docs/01-host-baseline.md) – Ausgangszustand des Homelab-Hosts
* [`02-srv-linux01.md`](docs/02-srv-linux01.md) – Aufbau und erste Überprüfung der Linux-Server-VM
* [`03-ssh.md`](docs/03-ssh.md) – Einrichtung und Test der SSH-Key-Authentifizierung

### Troubleshooting

* [`01-home-directory-permissions.md`](docs/troubleshooting/01-home-directory-permissions.md) – Fehlersuche bei einem Berechtigungsproblem im Home-Verzeichnis

### Begleitende Notizen

* [`glossar.md`](glossar.md) – Begriffe, die im Homelab verwendet werden

## Arbeitsweise

Bei Änderungen versuche ich nach einem festen Ablauf vorzugehen:

1. Ist-Zustand erfassen
2. technisches Verhalten verstehen
3. Änderung durchführen
4. Ergebnis testen
5. Erkenntnisse dokumentieren

Wenn etwas nicht funktioniert, möchte ich die Ursache nachvollziehen, bevor ich Änderungen vornehme.

Ein Beispiel dafür ist die dokumentierte Fehlersuche bei einem Zugriffsproblem auf `~/.ssh`. Statt die Berechtigungsfehlermeldung direkt mit `sudo` zu umgehen, wurden zunächst Eigentümer und Verzeichnisrechte geprüft und anschließend die eigentliche Ursache behoben.

## Nächste Schritte

Als Nächstes möchte ich den bestehenden Aufbau weiter vertiefen. Dazu gehören unter anderem:

* effektive SSH-Serverkonfiguration untersuchen
* Passwortauthentifizierung nach weiteren Tests bewerten
* Benutzer, Gruppen und Linux-Dateirechte praktisch vertiefen
* Prozesse, Services und systemd untersuchen
* Logs mit `journalctl` auswerten
* die vorbereitete LVM-Erweiterung praktisch durchführen
* Netzwerkdiagnose weiter ausbauen

Ein dedizierter Virtualisierungsserver und getrennte Netze mit VLANs sind mögliche spätere Ausbaustufen. Solche Erweiterungen möchte ich schrittweise umsetzen, wenn ich die dafür benötigten Grundlagen praktisch erarbeitet habe.

## Sicherheit

Passwörter, private Schlüssel, Tokens und andere Zugangsdaten werden nicht im Repository gespeichert.
