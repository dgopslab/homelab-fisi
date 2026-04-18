## Virtualisierung

Virtualisierung bedeutet, dass eine Software-Schicht so tut, als wäre sie ein eigener Computer, obwohl sie nur als Programm auf einem realen Rechner läuft. Diese Schicht heißt Hypervisor und sitzt zwischen echter Hardware und den Betriebssystemen darüber. Auf einem einzigen physischen Gerät arbeiten dadurch mehrere voneinander abgeschottete Systeme parallel, jedes davon denkt, es hätte den Rechner für sich.

Der Sinn dahinter ist Auslastung und Flexibilität. Ein moderner Mini-PC ist unterfordert, wenn nur Pi-hole darauf läuft. Packt man stattdessen Firewall, Windows Server und mehrere Linux-Dienste als virtuelle Maschinen (VMs) auf dieselbe Hardware, nutzt man das Gerät ehrlich aus. Dazu kommt, dass eine VM technisch gesehen eine Datei ist. Man kann sie kopieren, sichern, auf einen anderen Rechner umziehen oder per Snapshot in einen früheren Zustand zurücksetzen, falls beim Experimentieren etwas kaputtgeht.

Die echte Maschine, auf der der Hypervisor läuft, heißt Host. Die VMs, die er ausführt, heißen Gäste. In meinem Lab ist der Mini-PC der Host, Proxmox der Hypervisor, und OPNsense, Windows Server sowie Linux-Systeme sind die Gäste.
