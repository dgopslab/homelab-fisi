# srv-linux01 – Erste Linux-Server-VM

`srv-linux01` ist die erste Server-VM des Homelabs.

Sie dient als Lern- und Testsystem für Linux-Administration, Netzwerkdiagnose, SSH, Benutzer- und Rechteverwaltung sowie weitere Serverdienste. Inzwischen ist die VM außerdem Mitglied der Active-Directory-Domäne `ad.dgopslab.test`.

Die Domänenintegration ist in [Active Directory und Linux integrieren](05-active-directory-linux-integration.md) dokumentiert.

## VM-Konfiguration

Die virtuelle Maschine wurde über KVM/QEMU und libvirt eingerichtet.

Konfiguration:

* Hostname: `srv-linux01`
* Betriebssystem: Ubuntu Server 24.04.4 LTS
* vCPUs: 2
* Arbeitsspeicher: 4096 MiB
* virtuelle Festplatte: 30 GiB
* Festplattenformat: qcow2
* Disk-Bus: VirtIO
* Netzwerkinterface: VirtIO
* Netzwerk: libvirt `default`
* Netzwerkmodus: NAT

Die VM wurde bewusst zunächst mit vergleichsweise wenigen Ressourcen ausgestattet. Weitere virtuelle Maschinen sollen später parallel betrieben werden können. CPU, RAM und Speicher können bei Bedarf erweitert werden.

## Installationsmedium

Verwendet wurde das Ubuntu-Server-ISO:

`ubuntu-24.04.4-live-server-amd64.iso`

Vor der Installation wurde die SHA-256-Prüfsumme des Images mit der veröffentlichten Prüfsumme verglichen.

Damit wurde geprüft, ob die heruntergeladene Datei unverändert und vollständig vorliegt.

## Speicheraufbau

Die VM verwendet eine virtuelle Festplatte unter `/dev/vda`.

Ubuntu wurde mit LVM eingerichtet.

Vereinfachter Aufbau:

```text
/dev/vda
├── Boot-Bereich
├── /boot
└── LVM Physical Volume
    └── ubuntu-vg
        └── ubuntu-lv
            └── ext4 → /
```

Nach der Installation wurde nicht der gesamte verfügbare Speicher der Volume Group dem Root-Dateisystem zugewiesen.

Ein Teil des Speichers bleibt innerhalb der Volume Group frei und kann später für eine praktische LVM-Übung verwendet werden.

Dabei sollen unter anderem folgende Schritte untersucht werden:

* vorhandene Volumes prüfen
* Logical Volume vergrößern
* Dateisystem vergrößern
* Ergebnis kontrollieren

Eine zusätzliche LUKS-Verschlüsselung innerhalb der VM wurde zunächst nicht eingerichtet. Die Systemplatte des Hosts ist bereits verschlüsselt.

## Netzwerk

Die VM befindet sich im virtuellen libvirt-Netz:

```text
192.168.122.0/24
```

Das Netzwerkinterface innerhalb der VM heißt:

```text
enp1s0
```

Bei der ersten Überprüfung wurde die Netzwerkkonfiguration noch per DHCP bereitgestellt. Die VM erhielt damals die Adresse `192.168.122.156/24` und verwendete `192.168.122.1` als Gateway und DNS-Server.

Diese Werte dokumentieren den damaligen Ausgangszustand.

Für die spätere Active-Directory-Integration wurde eine feste Netzwerkkonfiguration eingerichtet:

| Einstellung | Aktueller Wert |
|---|---|
| IPv4-Adresse | `192.168.122.20/24` |
| Gateway | `192.168.122.1` |
| DNS-Server | `192.168.122.10` |
| DNS-Suchdomäne | `ad.dgopslab.test` |
| vollständiger Hostname | `srv-linux01.ad.dgopslab.test` |

`192.168.122.10` ist die Adresse des Domänencontrollers `DC01`. Der Server ist auf `srv-linux01` als einziger DNS-Server eingetragen, damit die AD-Domäne und ihre Dienste über den AD-DNS-Dienst gefunden werden können.

## Routing

Mit

```bash
ip route
```

wurde die Routingtabelle der VM geprüft.

Die Default Route zeigte auf:

```text
default via 192.168.122.1 dev enp1s0
```

Ziele innerhalb von `192.168.122.0/24` können direkt über `enp1s0` erreicht werden.

Ziele außerhalb des eigenen Netzes werden an das Default Gateway `192.168.122.1` weitergegeben.

## DNS

Bei der ersten Systemprüfung verwendete die VM noch den DNS-Server des libvirt-Netzes:

```text
192.168.122.1
```

Dieser historische Zustand wurde mit folgendem Befehl geprüft:

```bash
resolvectl status
```

Auch Forward- und Reverse-Lookups wurden damals getestet:

```bash
resolvectl query google.de
resolvectl query 1.1.1.1
```

Beide Tests waren erfolgreich.

Für die Active-Directory-Integration wurde die DNS-Konfiguration später geändert. Im aktuellen bestätigten Stand verwendet `srv-linux01` ausschließlich den AD-DNS-Server `192.168.122.10` und die DNS-Suchdomäne `ad.dgopslab.test`.

Die Auflösung der internen AD-Host- und Diensteinträge sowie die externe Namensauflösung wurden anschließend erneut geprüft. Weitere Einzelheiten stehen in [Active Directory und Linux integrieren](05-active-directory-linux-integration.md).

## SSH

Während der Ubuntu-Installation wurde der OpenSSH-Server eingerichtet.

Die grundlegende Anmeldung vom Homelab-Host auf `srv-linux01` wurde zunächst per Benutzerpasswort getestet.

Anschließend wurde ein eigenes Ed25519-Schlüsselpaar für das Homelab erstellt. Der öffentliche Schlüssel wurde auf `srv-linux01` hinterlegt und die Key-basierte Anmeldung erfolgreich getestet.

Zusätzlich wurde auf dem Pop!_OS-Host eine SSH-Client-Konfiguration eingerichtet, sodass die Verbindung über

```bash
ssh srv-linux01
```

hergestellt werden kann.

Der bereits für GitHub verwendete SSH-Schlüssel wurde dafür nicht wiederverwendet.

Die Einrichtung und die durchgeführten Prüfungen sind in [`03-ssh.md`](03-ssh.md) dokumentiert.

Die Passwortauthentifizierung wurde bisher nicht deaktiviert. Vor einer Änderung sollen zunächst die effektive SSH-Serverkonfiguration geprüft und die Key-basierte Anmeldung erneut über eine separate Sitzung getestet werden.

## Bisher überprüft

Folgende Funktionen wurden bisher geprüft:

- VM startet erfolgreich
- Netzwerkinterface ist aktiv
- DHCP-Zuweisung funktionierte im ursprünglichen Aufbau
- feste IPv4-Konfiguration ist eingerichtet
- Default Gateway ist vorhanden
- Routing in andere Netze funktioniert
- AD-DNS-Server und DNS-Suchdomäne sind eingetragen
- interne und externe Namensauflösung funktionieren
- SSH-Server ist installiert und erreichbar
- Key-basierte SSH-Authentifizierung funktioniert
- SSH-Client-Konfiguration für `srv-linux01` funktioniert
- Domänenbeitritt zu `ad.dgopslab.test` ist erfolgt
- AD-Benutzer und AD-Gruppen werden über SSSD aufgelöst
- gruppenbasierte Zugriffskontrolle über `Linux-Zugang` funktioniert
- Domänenintegration und Zugriffskontrolle bleiben nach einem Neustart erhalten

## Nächste Schritte

Für `srv-linux01` sind als Nächstes vorgesehen:

* effektive SSH-Serverkonfiguration untersuchen
* Passwortauthentifizierung nach weiteren Tests bewerten
* Paketverwaltung mit `apt`
* Benutzer und Gruppen
* Dateirechte
* `sudo`
* Prozesse und Services
* systemd
* Logs mit `journalctl`
* weitere Netzwerkdiagnose
* spätere LVM-Erweiterung
