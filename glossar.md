# Glossar

Dieses Glossar enthält Begriffe, die im Homelab verwendet werden. Die Erklärungen beziehen sich auf ihren Einsatz innerhalb des Projekts.

## Virtualisierung

Bei der Virtualisierung werden auf einem physischen Rechner mehrere voneinander getrennte virtuelle Systeme betrieben.

Eine zentrale Komponente ist der **Hypervisor**. Er stellt virtuellen Maschinen Ressourcen wie CPU, Arbeitsspeicher, Netzwerkinterfaces und virtuelle Datenträger zur Verfügung.

Der physische Rechner wird als **Host** bezeichnet. Die darauf betriebenen virtuellen Maschinen sind die **Gäste** beziehungsweise **VMs**.

Im aktuellen Homelab übernimmt KVM zusammen mit QEMU die Virtualisierung. libvirt dient als Verwaltungsschicht.

Durch Virtualisierung können mehrere Serversysteme auf derselben Hardware betrieben und unabhängig voneinander konfiguriert und getestet werden.

## VLAN – Virtual Local Area Network

Ein VLAN teilt ein physisches Netzwerk logisch in mehrere getrennte Layer-2-Netze auf.

Geräte in unterschiedlichen VLANs befinden sich in unterschiedlichen Broadcast-Domänen. Eine Kommunikation zwischen diesen Netzen benötigt Routing.

Bei VLAN-Verbindungen zwischen Netzwerkkomponenten wird häufig IEEE 802.1Q verwendet. Dabei kann ein Ethernet-Frame einen VLAN-Tag enthalten, über den er einem bestimmten VLAN zugeordnet wird.

In der geplanten Homelab-Architektur sollen VLANs beispielsweise unterschiedliche Bereiche voneinander trennen:

* Management
* Server
* Clients und Testsysteme

Welche Kommunikation zwischen diesen Netzen erlaubt ist, soll später über Routing und Firewall-Regeln festgelegt werden.

