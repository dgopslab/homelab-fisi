# Homelab Host – Ausgangszustand

Vor dem Aufbau der ersten virtuellen Maschinen wurde der vorhandene Desktop-PC als Homelab-Host überprüft.

Ziel der Bestandsaufnahme war festzustellen, ob Hardware, Betriebssystem, Virtualisierung und Netzwerk für den Aufbau der Lab-Umgebung geeignet sind.

## Host

* Betriebssystem: Pop!_OS 22.04 LTS
* Arbeitsspeicher: ca. 31 GiB
* logische CPUs: 16
* Hardwarevirtualisierung: AMD-V aktiv
* KVM verfügbar
* Virtualisierung: KVM/QEMU mit libvirt
* Verwaltung: virt-manager und virsh

Die Hardwarevirtualisierung und der Zugriff auf `/dev/kvm` wurden vor der Einrichtung der ersten VM geprüft.

## Speicher

Die Linux-Systemplatte verwendet:

* NVMe
* LUKS
* LVM
* ext4

Für die virtuellen Maschinen wird ein libvirt Storage Pool unter `/var/lib/libvirt/images` verwendet.

## Netzwerk

Heimnetz:

`192.168.178.0/24`

Virtuelles libvirt-Netz:

`192.168.122.0/24`

Konfiguration des virtuellen Netzes:

* Bridge: `virbr0`
* Gateway: `192.168.122.1`
* Netzwerkmodus: NAT
* DHCP über libvirt
* IPv4-Forwarding auf dem Host aktiv

Virtuelle Maschinen können dadurch über den Host auf andere Netze beziehungsweise das Internet zugreifen, ohne direkt im Heimnetz betrieben zu werden.

## Remotezugriff

Für den Remotezugriff auf den Homelab-Host wird Tailscale verwendet.

Eingerichtet und getestet wurden:

* Tailscale auf dem Pop!_OS-Host
* Tailscale SSH
* externer Zugriff über ein anderes Netzwerk

Zugangsdaten und private Schlüssel werden nicht im Repository dokumentiert.

## Ergebnis

Der vorhandene Rechner erfüllt die Anforderungen für die aktuelle erste Ausbaustufe des Homelabs.

Ein dedizierter Virtualisierungsserver ist für einen späteren Ausbau vorgesehen, für die derzeitigen Linux-, Netzwerk- und Virtualisierungsübungen jedoch noch nicht erforderlich.

