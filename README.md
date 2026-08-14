# Homelab FISI

Dieses Repository dokumentiert mein persönliches Homelab während meiner Umschulung zum Fachinformatiker für Systemintegration.

Das Lab dient dazu, Themen aus der Umschulung praktisch umzusetzen und technische Zusammenhänge nicht nur theoretisch, sondern an realen Systemen nachzuvollziehen.

## Aktueller Aufbau

Das Homelab läuft derzeit auf meinem Desktop-PC unter Pop!_OS.

Eingesetzte Komponenten:

* KVM/QEMU zur Virtualisierung
* libvirt zur Verwaltung der virtuellen Umgebung
* virt-manager und virsh zur Administration
* libvirt-NAT-Netzwerk für die virtuellen Maschinen
* Ubuntu Server als erste Server-VM
* SSH für die Remoteadministration
* Tailscale für den externen Zugriff auf den Homelab-Host

Die erste virtuelle Maschine ist:

`srv-linux01` – Ubuntu Server 24.04 LTS

## Aktuelle Lernbereiche

Im Lab beschäftige ich mich derzeit unter anderem mit:

* Linux-Serveradministration
* IPv4, Routing, DNS und DHCP
* Virtualisierung
* SSH und Authentifizierung
* Benutzer- und Rechteverwaltung
* Fehlersuche und Netzwerkdiagnose
* Git und technischer Dokumentation

## Zielarchitektur

Langfristig soll das Homelab auf einen dedizierten Server umziehen und schrittweise erweitert werden.

Geplant sind unter anderem:

* Proxmox VE
* OPNsense
* Managed Switch und VLANs
* Windows Server und Active Directory
* Linux-Server
* DNS und DHCP
* Monitoring
* Docker und weitere Container-Dienste

Die Architektur wird erst erweitert, wenn die jeweiligen Grundlagen praktisch verstanden und getestet wurden.

## Dokumentation

Technische Schritte und überprüfte Systemzustände werden unter [`docs/`](docs/) dokumentiert.

Aktuell vorhanden:

* [`01-host-baseline.md`](docs/01-host-baseline.md) – Ausgangszustand des Homelab-Hosts
* [`glossar.md`](glossar.md) – Begriffe, die im Projekt verwendet werden

Die Dokumentation wächst zusammen mit dem Lab.

## Arbeitsweise

Bei Änderungen versuche ich nach einem festen Schema vorzugehen:

1. Ist-Zustand erfassen
2. technisches Verhalten verstehen
3. Änderung durchführen
4. Ergebnis testen
5. Erkenntnisse dokumentieren

Konfigurationen werden nicht nur übernommen, sondern möglichst auf ihre Funktion und Auswirkungen untersucht.

Passwörter, private Schlüssel, Tokens und andere Zugangsdaten werden nicht im Repository gespeichert.

