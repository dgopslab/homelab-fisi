# Homelab FISI

Dieses Repository dokumentiert mein persönliches Homelab während meiner Umschulung zum **Fachinformatiker für Systemintegration**.

Ich nutze das Lab, um Themen aus der Umschulung praktisch nachzuvollziehen, Konfigurationen selbst auszuprobieren und auftretende Fehler systematisch zu untersuchen.

## Aktueller Aufbau

Das Homelab läuft derzeit auf meinem Desktop-PC unter **Pop!_OS 22.04 LTS**.

Für die Virtualisierung verwende ich:

- KVM/QEMU
- libvirt
- virt-manager und virsh
- das libvirt-Netzwerk `default` im NAT-Modus

Im virtuellen Netz `192.168.122.0/24` laufen derzeit zwei Server-VMs:

| VM | System | Rolle | IPv4-Adresse |
|---|---|---|---|
| `DC01` | Windows Server 2025 | Domänencontroller mit Active Directory und DNS für `ad.dgopslab.test` | `192.168.122.10` |
| `srv-linux01` | Ubuntu Server 24.04.4 LTS | Linux-Server, Mitglied der AD-Domäne | `192.168.122.20` |

`srv-linux01` verwendet eine feste Netzwerkkonfiguration und nutzt `DC01` als DNS-Server.

Für den Zugriff von unterwegs nutze ich Cloudflare Tunnel mit Cloudflare Access. Tailscale hatte ich zuerst eingesetzt, am Schulungsstandort funktionierte es nicht. Die Entscheidung und der Aufbau stehen in [`06-fernzugriff-cloudflare.md`](docs/06-fernzugriff-cloudflare.md).

## Bisher umgesetzt und untersucht

Im bisherigen Aufbau habe ich unter anderem:

- den Homelab-Host und seine Virtualisierungsumgebung überprüft
- eine Ubuntu-Server-VM mit KVM/QEMU und libvirt eingerichtet
- das virtuelle NAT-Netzwerk sowie Gateway, Routing und DNS-Verhalten untersucht
- die VM über SSH administriert
- ein eigenes Ed25519-Schlüsselpaar für das Homelab eingerichtet
- die SSH-Client-Konfiguration für `srv-linux01` eingerichtet und getestet
- Linux-Datei- und Verzeichnisrechte bei einer konkreten Berechtigungsstörung untersucht
- einen Windows Server als Domänencontroller mit Active Directory und AD-integriertem DNS eingerichtet
- eine OU-Struktur, AD-Testbenutzer und die Sicherheitsgruppe `Linux-Zugang` angelegt
- `srv-linux01` mit realmd, adcli und SSSD in die Domäne eingebunden
- die AD-Anmeldung auf Mitglieder von `Linux-Zugang` beschränkt und mit einem berechtigten und einem nicht berechtigten Testbenutzer geprüft, auch nach einem Neustart
- zwei getrennte Kerberos-Probleme beim Domänenbeitritt untersucht und behoben
- einen Fernzugriff auf Cockpit über Cloudflare Tunnel und Cloudflare Access aufgebaut, mit Einmal-PIN abgesichert und vom Schulungsstandort aus getestet; die Fehlersuche bei einer Anmeldeschleife dokumentiert

Dabei dokumentiere ich möglichst nicht nur die verwendeten Befehle, sondern auch, was ich damit prüfe und wie ich das Ergebnis einordne.

## Dokumentation

### Aufbau und Systeme

- [`01-host-baseline.md`](docs/01-host-baseline.md) – Ausgangszustand des Homelab-Hosts
- [`02-srv-linux01.md`](docs/02-srv-linux01.md) – Aufbau und erste Überprüfung der Linux-Server-VM
- [`03-ssh.md`](docs/03-ssh.md) – Einrichtung und Test der SSH-Key-Authentifizierung
- [`04-network-path-libvirt-nat.md`](docs/04-network-path-libvirt-nat.md) – Untersuchung eines IPv4-Paketwegs durch das libvirt-NAT-Netz
- [`05-active-directory-linux-integration.md`](docs/05-active-directory-linux-integration.md) – Einbindung von `srv-linux01` in Active Directory mit gruppenbasierter Zugriffskontrolle
- [`06-fernzugriff-cloudflare.md`](docs/06-fernzugriff-cloudflare.md) – Fernzugriff über Cloudflare Tunnel und Cloudflare Access: Entscheidung, Aufbau, Tests, Fehlersuche und Grenzen

### Troubleshooting

- [`01-home-directory-permissions.md`](docs/troubleshooting/01-home-directory-permissions.md) – Fehlersuche bei einem Berechtigungsproblem im Home-Verzeichnis
- [Fehlgeschlagener Domänenbeitritt](docs/05-active-directory-linux-integration.md#troubleshooting) – fehlender Kerberos-Standard-Realm und Anmeldeproblem beim Join-Konto (Abschnitt in `05`)

### Begleitende Notizen

- [`glossar.md`](glossar.md) – Begriffe, die im Homelab verwendet werden

## Arbeitsweise

Bei Änderungen versuche ich nach einem festen Ablauf vorzugehen:

1. Ist-Zustand erfassen
2. technisches Verhalten verstehen
3. Änderung durchführen
4. Ergebnis testen
5. Erkenntnisse dokumentieren

Wenn etwas nicht funktioniert, möchte ich die Ursache nachvollziehen, bevor ich Änderungen vornehme.

Ein Beispiel dafür ist die dokumentierte Fehlersuche bei einem Zugriffsproblem auf `~/.ssh`. Statt die Berechtigungsfehlermeldung direkt mit `sudo` zu umgehen, wurden zunächst Eigentümer und Verzeichnisrechte geprüft und die fehlerhaften Berechtigungen anschließend gezielt korrigiert.

Ein weiteres Beispiel ist der fehlgeschlagene Domänenbeitritt. Bevor das Kennwort des Join-Kontos neu gesetzt wurde, wurde auf `DC01` geprüft, ob das Konto gesperrt oder das Kennwort abgelaufen war.

### Einsatz von KI

Ich nutze KI als Werkzeug und Sparringspartner, vor allem für Recherche, den Vergleich von Alternativen und die Fehlersuche. Vorschläge und Anleitungen übernehme ich nicht ungeprüft: Ich führe die Schritte selbst aus, teste das Ergebnis und halte meine Entscheidungen mit Begründung fest. Welche Rolle KI bei einem Thema hatte, steht im jeweiligen Dokument.

## Nächste Schritte

Als Nächstes möchte ich den bestehenden Aufbau weiter vertiefen. Dazu gehören unter anderem:

- den bestehenden Zustand prüfen: Rückfallverfahren an einer Kopie ausprobieren und den Testzeitraum von `DC01` (Windows Server 2025 Evaluation) kontrollieren
- den Fernzugriff abschließen: Notfall-Abschaltung testen, RDP im Browser für `DC01` einrichten
- die Zielarchitektur des Netzes festlegen und eine IPv6-Adresse auslesen und erklären
- einen Windows-11-Client einrichten, testen und ein Übergabeprotokoll schreiben

Ein dedizierter Virtualisierungsserver, getrennte Netze mit VLANs, ein zweiter Domänencontroller und eine unabhängige Sicherungsstrategie für Active Directory sind mögliche spätere Ausbaustufen. Solche Erweiterungen möchte ich schrittweise umsetzen, wenn ich die dafür benötigten Grundlagen praktisch erarbeitet habe.

## Sicherheit

Passwörter, private Schlüssel, Tokens und andere Zugangsdaten werden nicht im Repository gespeichert. Der Fernzugriff läuft über einen ausgehenden Tunnel, eine Portweiterleitung am Router habe ich dafür nicht eingerichtet. Domainname, Tunnel-Konfiguration und Zugangsdaten stehen nicht im Repository; Einschätzung und Grenzen der Absicherung stehen in [`06-fernzugriff-cloudflare.md`](docs/06-fernzugriff-cloudflare.md). Kontonamen und Kennwörter aus dem AD-Aufbau sowie Inhalte der Kerberos-Keytab werden nicht dokumentiert.
