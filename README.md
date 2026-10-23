# Homelab FISI

Dieses Repository dokumentiert mein persönliches Homelab während meiner Umschulung zum Fachinformatiker für Systemintegration.

Ich nutze das Lab, um Unterrichtsthemen praktisch nachzuvollziehen, Systeme einzurichten und Fehler zu untersuchen. Die Dokumentation hält fest, welche Schritte ich durchgeführt habe, welche Ergebnisse geprüft sind und welche Fragen offenbleiben.

## Aktueller Aufbau

Das Homelab läuft auf meinem Desktop-PC unter Pop!_OS 22.04 LTS. Für die Virtualisierung verwende ich KVM/QEMU mit libvirt, virt-manager und virsh.

Zwei Server-VMs bilden eine Windows-/Linux-Domänenumgebung im libvirt-Netz `default`. Das Netz verwendet NAT und den IPv4-Adressbereich `192.168.122.0/24`.

| VM | System | Rolle | IPv4-Adresse |
|---|---|---|---|
| `dc01` | Windows Server 2025 Standard Evaluation | Domänencontroller mit Active Directory und DNS für `ad.dgopslab.test`; DHCP-Rolle eingerichtet | `192.168.122.10` |
| `srv-linux01` | Ubuntu Server 24.04.4 LTS | AD-Domänenmitglied mit SSSD; AD-Anmeldung auf eine Sicherheitsgruppe beschränkt | `192.168.122.20` |

Beide Server verwenden feste IPv4-Adressen. Die Konfiguration wurde unter Windows mit `ipconfig /all` und unter Linux anhand von Netplan sowie der aktuell verwendeten Adresse geprüft. Die Linux-VM nutzt `dc01` als DNS-Server, `ad.dgopslab.test` als DNS-Suchdomäne und `192.168.122.1` als Gateway.

Auf `dc01` habe ich die DHCP-Rolle eingerichtet, einen Bereich von `192.168.122.100` bis `192.168.122.199` angelegt und den Server in Active Directory autorisiert. Den DHCP-Abschnitt habe ich aus der gespeicherten libvirt-Netzdefinition entfernt und das virtuelle Netz anschließend neu gestartet.

Die abschließende Kontrolle der laufenden Netzdefinition und der DHCP-Test mit einem Client stehen noch aus. Die Umstellung ist damit noch nicht vollständig verifiziert.

Für den Zugriff von unterwegs verwende ich Cloudflare Tunnel mit Cloudflare Access und die Cockpit-Weboberfläche. Den Zugriff vom Schulungsstandort habe ich getestet. Tailscale hatte ich zuvor ausprobiert; dort kam keine Verbindung zustande. Aufbau, Fehlersuche und Grenzen stehen in der [Fernzugriffsdokumentation](docs/06-fernzugriff-cloudflare.md).

## Bisher umgesetzt und untersucht

- Den Homelab-Host und die Virtualisierungsumgebung überprüft.
- Eine Ubuntu-Server-VM eingerichtet und deren Speicher-, Netzwerk- und DNS-Konfiguration untersucht.
- Einen IPv4-Paketweg durch das libvirt-NAT-Netz nachvollzogen.
- SSH-Zugriff mit einem eigenen Ed25519-Schlüsselpaar eingerichtet und die SSH-Client-Konfiguration getestet.
- Eine Berechtigungsstörung im Home-Verzeichnis untersucht und die Verzeichnisrechte gezielt korrigiert.
- Active Directory mit AD-integriertem DNS, einer OU-Struktur und Testkonten aufgebaut.
- Die Linux-VM mit realmd, adcli und SSSD in die Domäne eingebunden.
- Die AD-Anmeldung auf die Sicherheitsgruppe `Linux-Zugang` beschränkt und mit einem berechtigten und einem nicht berechtigten Konto getestet, auch nach einem Neustart.
- Zwei getrennte Kerberos-Probleme beim Domänenbeitritt untersucht und behoben.
- Fernzugriff über Cloudflare und Cockpit eingerichtet, vom Schulungsstandort getestet und eine Anmeldeschleife untersucht.
- Einen manuellen Betriebscheck dokumentiert.
- Die DHCP-Rolle auf `dc01` eingerichtet und die libvirt-Netzdefinition für die Ablösung des bisherigen DHCP-Dienstes geändert.

Diese Punkte beschreiben den jeweiligen dokumentierten Teststand. Sie ersetzen keine erneute Prüfung nach späteren Änderungen.

## Dokumentation

### Aufbau und Systeme

- [`01-host-baseline.md`](docs/01-host-baseline.md) – Ausgangszustand des Homelab-Hosts
- [`02-srv-linux01.md`](docs/02-srv-linux01.md) – Aufbau und erste Überprüfung der Linux-Server-VM
- [`03-ssh.md`](docs/03-ssh.md) – Einrichtung und Test der SSH-Key-Authentifizierung
- [`04-network-path-libvirt-nat.md`](docs/04-network-path-libvirt-nat.md) – Untersuchung eines IPv4-Paketwegs durch das libvirt-NAT-Netz
- [`05-active-directory-linux-integration.md`](docs/05-active-directory-linux-integration.md) – Domänenbeitritt und gruppenbasierte Zugriffskontrolle auf der Linux-VM
- [`06-fernzugriff-cloudflare.md`](docs/06-fernzugriff-cloudflare.md) – Fernzugriff, Tests, Fehlersuche und Grenzen der Absicherung
- [`07-betriebscheck.md`](docs/07-betriebscheck.md) – manueller Betriebscheck und erster dokumentierter Teillauf

### Troubleshooting

- [`01-home-directory-permissions.md`](docs/troubleshooting/01-home-directory-permissions.md) – Berechtigungsproblem im Home-Verzeichnis
- [Fehlgeschlagener Domänenbeitritt](docs/05-active-directory-linux-integration.md#troubleshooting) – fehlender Kerberos-Standard-Realm und Authentifizierungsproblem beim Join-Konto

### Begleitende Notizen

- [`glossar.md`](glossar.md) – Begriffe aus dem Homelab

Die DHCP-Einrichtung und neuere Betriebsprüfungen sind bisher in meinen privaten Lernnotizen festgehalten. Die bereinigte Dokumentation möchte ich in dieses Repository übernehmen.

## Arbeitsweise

Bei Änderungen orientiere ich mich an diesem Ablauf:

1. Ist-Zustand erfassen
2. Verhalten und mögliche Ursachen untersuchen
3. Änderung durchführen
4. Ergebnis testen
5. Erkenntnisse und offene Fragen dokumentieren

Bei einem Zugriffsproblem auf `~/.ssh` habe ich zunächst Eigentümer und Verzeichnisrechte geprüft, bevor die Berechtigungen korrigiert wurden.

Beim fehlgeschlagenen Domänenbeitritt wurden auf `dc01` unter anderem Kontosperre und Kennwortablauf geprüft, bevor das nicht mehr sicher bekannte Kennwort des Join-Kontos neu gesetzt wurde.

Die DHCP-Umstellung zeigt zugleich eine Grenze des bisherigen Stands: Die Einrichtung ist dokumentiert, der Nachweis einer tatsächlichen Adressvergabe fehlt noch. Diesen Unterschied halte ich ausdrücklich fest.

### Einsatz von KI

Ich nutze einen KI-Assistenten für Erklärungen, die Planung von Arbeitsschritten und die Fehlersuche. Die Einrichtung und die dokumentierten Tests führe ich selbst durch; Befehlsausgaben werte ich teilweise gemeinsam mit dem Assistenten aus. In den Fachnotizen halte ich fest, welche Unterstützung ich genutzt habe und welche Ergebnisse tatsächlich geprüft wurden.

## Nächste Schritte

- Die laufende libvirt-Netzdefinition nach der DHCP-Änderung kontrollieren.
- Einen Windows-11-Client einrichten und die DHCP-Vergabe einschließlich Gateway, DNS-Einstellungen und Lease-Eintrag auf `dc01` testen.
- Offene DHCP-Konfigurationsfragen klären, insbesondere die Reservierung außerhalb des Verteilbereichs und die Nacharbeiten der Rolleninstallation.
- Die Wiederherstellung aus der VM-Sicherung an einer Kopie erproben.
- Die DHCP-Prüfungen in den Betriebscheck aufnehmen.
- Die DHCP-Dokumentation und neuere Prüfergebnisse für die Veröffentlichung aufbereiten.
- Den Fernzugriff um RDP im Browser für `dc01` erweitern.
- Die Zielarchitektur des Netzes festlegen und die vorhandene IPv6-Konfiguration untersuchen.
- Den verbleibenden Evaluierungszeitraum von Windows Server kontrollieren und den weiteren Betrieb planen.

Ein dedizierter Virtualisierungsserver, getrennte Netze mit VLANs und ein zweiter Domänencontroller sind mögliche spätere Ausbaustufen. Auch eine unabhängige Sicherungs- und Wiederherstellungsstrategie für Active Directory gehört zu den offenen Ausbauzielen.

## Sicherheit

Zugangsdaten für das Lab verwahre ich in einem Passwortmanager außerhalb dieses Repositorys. Passwörter, private Schlüssel, Tokens und Kerberos-Keytab-Inhalte gehören nicht in die veröffentlichte Dokumentation.

Der Fernzugriff erfolgt über einen ausgehenden Cloudflare Tunnel ohne dafür eingerichtete Portweiterleitung am Router. Cloudflare Access schützt den Zugang zu Cockpit; anschließend ist eine Anmeldung mit einem Systemkonto erforderlich.

Die Grenzen dieser Absicherung und bisher nicht durchgeführte Sicherheitsprüfungen sind in der [Fernzugriffsdokumentation](docs/06-fernzugriff-cloudflare.md#grenzen-und-sicherheitsbewertung) beschrieben. Der Aufbau dient als Lernumgebung und ist keine Vorlage für einen unveränderten Produktiveinsatz.
