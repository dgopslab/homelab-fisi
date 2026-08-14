# srv-linux01 – Erste Linux-Server-VM

`srv-linux01` ist die erste Server-VM des Homelabs.

Sie dient als Lern- und Testsystem für Linux-Administration, Netzwerkdiagnose, SSH, Benutzer- und Rechteverwaltung sowie spätere Serverdienste.

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

`192.168.122.0/24`

Das Netzwerkinterface innerhalb der VM heißt:

`enp1s0`

Die Netzwerkkonfiguration wird derzeit per DHCP bereitgestellt.

Bei der ersten Überprüfung erhielt die VM die Adresse:

`192.168.122.156/24`

Standardgateway:

`192.168.122.1`

DNS-Server:

`192.168.122.1`

Die Adresse der VM kann sich durch DHCP zukünftig ändern.

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

Die DNS-Konfiguration wurde mit

```bash
resolvectl status
```

überprüft.

Als DNS-Server verwendet die VM derzeit:

`192.168.122.1`

Die Namensauflösung wurde zusätzlich praktisch getestet.

Forward Lookup:

```bash
resolvectl query google.de
```

Dabei wird ein Hostname in eine IP-Adresse aufgelöst.

Reverse Lookup:

```bash
resolvectl query 1.1.1.1
```

Dabei wird zu einer IP-Adresse ein zugehöriger Name abgefragt.

Beide Tests waren erfolgreich.

## SSH

Während der Ubuntu-Installation wurde der OpenSSH-Server eingerichtet.

Damit kann die VM vom Homelab-Host aus über SSH administriert werden.

Aktuell wird zunächst die grundlegende SSH-Verbindung verwendet. Als nächster Schritt soll die Authentifizierung auf einen eigenen SSH-Schlüssel für das Homelab umgestellt werden.

Geplant:

1. eigenen SSH-Schlüssel für das Homelab erstellen
2. Public Key auf `srv-linux01` hinterlegen
3. Anmeldung per Schlüssel testen
4. Passwortauthentifizierung anschließend überprüfen und gegebenenfalls deaktivieren

Der bereits für GitHub verwendete private Schlüssel soll dafür nicht wiederverwendet werden.

## Bisher überprüft

Folgende Funktionen wurden nach der Installation geprüft:

* VM startet erfolgreich
* Netzwerkinterface ist aktiv
* DHCP funktioniert
* Default Gateway ist vorhanden
* Routing in andere Netze funktioniert
* DNS-Konfiguration ist vorhanden
* Forward-DNS funktioniert
* Reverse-DNS funktioniert
* SSH-Server ist installiert und erreichbar

## Nächste Schritte

Für `srv-linux01` sind als Nächstes vorgesehen:

* SSH-Key-Authentifizierung
* Paketverwaltung mit `apt`
* Benutzer und Gruppen
* Dateirechte
* `sudo`
* Prozesse und Services
* systemd
* Logs mit `journalctl`
* weitere Netzwerkdiagnose
* spätere LVM-Erweiterung
