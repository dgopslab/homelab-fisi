# Homelab Host – Ausgangszustand

## Host

- Betriebssystem: Pop!_OS 22.04 LTS
- RAM: ca. 31 GiB
- Hardwarevirtualisierung: AMD-V / KVM aktiv
- Virtualisierung: KVM, QEMU und libvirt
- Verwaltung: virt-manager und virsh

## Netzwerk

- Heimnetz: 192.168.178.0/24
- Ethernet: 192.168.178.34
- libvirt-Netz: 192.168.122.0/24
- libvirt-Gateway: 192.168.122.1
- Netzwerkmodus: NAT

## Remotezugriff

- Tailscale eingerichtet
- Tailscale SSH aktiviert
- Remotezugriff über Mobilfunk erfolgreich getestet
