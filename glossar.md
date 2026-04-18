## Virtualisierung

Virtualisierung bedeutet, dass eine Software-Schicht so tut, als wäre sie ein eigener Computer, obwohl sie nur als Programm auf einem realen Rechner läuft. Diese Schicht heißt Hypervisor und sitzt zwischen echter Hardware und den Betriebssystemen darüber. Auf einem einzigen physischen Gerät arbeiten dadurch mehrere voneinander abgeschottete Systeme parallel, jedes davon denkt, es hätte den Rechner für sich.

Der Sinn dahinter ist Auslastung und Flexibilität. Ein moderner Mini-PC ist unterfordert, wenn nur Pi-hole darauf läuft. Packt man stattdessen Firewall, Windows Server und mehrere Linux-Dienste als virtuelle Maschinen (VMs) auf dieselbe Hardware, nutzt man das Gerät ehrlich aus. Dazu kommt, dass eine VM technisch gesehen eine Datei ist. Man kann sie kopieren, sichern, auf einen anderen Rechner umziehen oder per Snapshot in einen früheren Zustand zurücksetzen, falls beim Experimentieren etwas kaputtgeht.

Die echte Maschine, auf der der Hypervisor läuft, heißt Host. Die VMs, die er ausführt, heißen Gäste. In meinem Lab ist der Mini-PC der Host, Proxmox der Hypervisor, und OPNsense, Windows Server sowie Linux-Systeme sind die Gäste.

## VLAN (Virtual Local Area Network)

Ein VLAN ist ein logisch abgegrenztes Netzwerk innerhalb eines physischen Switches. Mehrere VLANs teilen sich dieselbe Hardware, sehen sich aber gegenseitig nicht, als wären es separate Switches. Möglich macht das ein kleiner Anhang an jedem Datenpaket, die VLAN-ID, anhand der der Switch entscheidet, wohin er das Paket weiterleiten darf. Der zugrundeliegende Standard heißt 802.1Q.

Der Sinn dahinter ist Trennung. Server, Clients, Management-Zugänge und experimentelle Test-Maschinen lassen sich in eigene Bereiche stecken, ohne dass man für jeden Bereich einen eigenen Switch kaufen muss. Wer in einem VLAN sitzt, kann ein Gerät im anderen VLAN nicht direkt erreichen, sondern nur über einen Router, der dazwischen vermittelt. Genau dort greifen dann Firewall-Regeln, die festlegen, wer mit wem reden darf.

In meinem Lab trennen VLANs die Verwaltung (Proxmox-Oberfläche, OPNsense-Admin), die Server-Dienste (Active Directory, Linux-Anwendungen) und die Test-Clients voneinander. Eine kompromittierte Test-VM erreicht so weder den AD-Server noch die Lab-Verwaltung, solange OPNsense nichts erlaubt.
