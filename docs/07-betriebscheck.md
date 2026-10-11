# Betriebscheck für den vorhandenen Homelab-Aufbau

Dieser manuelle Check gehört zu Phase 0 der privaten Homelab-Roadmap. Er prüft den aktuellen Zustand, ohne eine frühere erfolgreiche Einrichtung mit heutiger Verfügbarkeit gleichzusetzen. Befehle werden vom Pop!_OS-Host ausgeführt, sofern kein anderer Ort genannt ist. Es werden keine VMs gestartet oder Einstellungen geändert.

**Begriffe:** VM = virtuelle Maschine; NAT = Network Address Translation (Adressübersetzung); IP = Internet Protocol; DNS = Domain Name System (Namensauflösung); AD = Active Directory; SRV-Eintrag = DNS-Diensteintrag; SSSD = System Security Services Daemon (Linux-Anbindung an die Domäne); SSH = Secure Shell; TCP = Transmission Control Protocol; WinRM = Windows Remote Management; RDP = Remote Desktop Protocol; HTTP = Hypertext Transfer Protocol.

## 1. Virtualisierung und VM-Status

**FRAGE:** Ist das virtuelle NAT-Netz aktiv, und laufen die beiden VMs?

**BEFEHL:**

```bash
virsh -c qemu:///system net-info default
virsh -c qemu:///system list --all
```

**WORAUF ACHTEN:** `Active: yes`, `Bridge: virbr0` und der Zustand von `dc01` und `srv-linux01`. `shut off` bedeutet ausgeschaltet. Bei ausgeschalteter VM die zugehörigen Prüfungen unten als *nicht ausgeführt* markieren.

**BEDEUTUNG:** Das prüft die libvirt-Basis und zeigt, ob weitere Live-Tests möglich sind. Ein aktives Netz beweist noch keine Funktion von DNS oder AD.

## 2. Erreichbarkeit und DNS

**FRAGE:** Antworten die VMs im virtuellen Netz und liefert der AD-DNS-Server die erwarteten Host- und Diensteinträge?

**BEFEHL:** Nur bei laufenden VMs auf dem Host ausführen:

```bash
ping -c 2 192.168.122.10
ping -c 2 192.168.122.20
host dc01.ad.dgopslab.test 192.168.122.10
host srv-linux01.ad.dgopslab.test 192.168.122.10
host -t SRV _ldap._tcp.dc._msdcs.ad.dgopslab.test 192.168.122.10
host -t SRV _kerberos._tcp.ad.dgopslab.test 192.168.122.10
```

**WORAUF ACHTEN:** Ping-Antworten, passende Adressen und SRV-Ziele für den Domänencontroller. Ausbleibende Ping-Antworten allein beweisen keinen VM-Ausfall; die Firewall kann Internet Control Message Protocol (ICMP) blockieren.

**BEDEUTUNG:** Die Abfragen trennen IP-Erreichbarkeit von Namensauflösung und AD-Diensterkennung. Ein DNS-Eintrag belegt noch keinen laufenden Dienst.

## 3. Linux-Domänenintegration und SSH

**FRAGE:** Ist die Domäne auf `srv-linux01` weiterhin konfiguriert, kann SSSD einen berechtigten AD-Benutzer auflösen, und funktioniert der lokale Rückfallzugang?

**BEFEHL:** Nach erfolgreichem SSH-Login auf `srv-linux01` ausführen; den Platzhalter nur lokal ersetzen:

```bash
realm list
systemctl is-active sssd
getent passwd '<berechtigter-ad-benutzer>@ad.dgopslab.test'
```

Für den lokalen Rückfallzugang vom Host aus eine eigene SSH-Sitzung öffnen:

```bash
ssh srv-linux01
```

**WORAUF ACHTEN:** `realm list` zeigt die konfigurierte Domäne, SSSD meldet `active`, `getent` liefert einen Benutzereintrag, und die SSH-Anmeldung gelingt. Ein fehlender Eintrag verlangt weitere Diagnose; er beweist allein noch keine defekte Domäne.

**BEDEUTUNG:** Konfiguration, Dienstzustand, Benutzerauflösung und echte Anmeldung werden getrennt geprüft. Ein Kerberos-Ticket oder eine erneute erlaubte und verweigerte AD-Anmeldung ist dadurch noch nicht nachgewiesen.

## 4. Kerberos und Zugriffsregel

**FRAGE:** Funktioniert die aktuelle AD-Authentifizierung für ein berechtigtes Konto, und wird ein nicht berechtigtes Konto weiterhin abgewiesen?

**BEFEHL:** Diese interaktiven Tests werden auf `srv-linux01` mit dafür vorgesehenen Testkonten durchgeführt. `kinit` erzeugt ein zeitlich begrenztes Ticket im Benutzerkontext; Zugangsdaten und Ticketausgaben werden nicht protokolliert.

```bash
kinit '<berechtigter-ad-benutzer>@AD.DGOPSLAB.TEST'
klist -s
kdestroy
sssctl user-checks '<berechtigter-ad-benutzer>@ad.dgopslab.test'
sssctl user-checks '<nicht-berechtigter-ad-benutzer>@ad.dgopslab.test'
```

**WORAUF ACHTEN:** `kinit` und `klist -s` gelingen; die Kontoprüfung erlaubt das berechtigte und verweigert das nicht berechtigte Konto. Danach die beiden tatsächlichen SSH-Anmeldungen getrennt prüfen und nur deren Ergebnis notieren.

**BEDEUTUNG:** Erst die Kombination aus Ticket-, Kontoprüfung und echten Anmeldeversuchen belegt den aktuellen Authentifizierungs- und Zugriffsstand. Keine Kennwörter oder Ticketinhalte dokumentieren.

## 5. WinRM und RDP

**FRAGE:** Ist der Windows-Server aus dem vorgesehenen Clientnetz erreichbar und funktionieren die beiden Remote-Anmeldungen?

**BEFEHL:** Vom Host aus zunächst nur die TCP-Ports prüfen:

```bash
nc -z -w 2 192.168.122.10 5985
nc -z -w 2 192.168.122.10 3389
```

Für WinRM anschließend von einem dafür eingerichteten PowerShell-Client `Test-WSMan dc01.ad.dgopslab.test` und eine interaktive PowerShell-Remoting-Sitzung prüfen. RDP mit einem grafischen Client und einem vorgesehenen Konto anmelden.

**WORAUF ACHTEN:** Ein offener Port zeigt nur einen erreichbaren Listener. Erst eine erfolgreiche Remoting-Sitzung beziehungsweise RDP-Anmeldung belegt die jeweilige Funktion. Port 5985 ist der HTTP-Listener von WinRM; die Portprüfung bewertet keine Sitzungssicherheit.

**BEDEUTUNG:** Transport, Dienstantwort und echte Anmeldung sind getrennte Prüfstufen. Fehlende Clients oder Anmeldedaten werden als *nicht geprüft* erfasst.

## Erster Teillauf am 27.09.2026

| Prüfung | Beobachtung | Einordnung |
|---|---|---|
| libvirt-Netz `default` | aktiv, persistent, Autostart; Bridge `virbr0` | Basis vorhanden |
| `dc01` und `srv-linux01` | beide `shut off` | Live-Prüfungen derzeit nicht möglich |
| Ping, DNS, AD-SRV, Kerberos, SSSD, SSH, WinRM, RDP | nicht ausgeführt | kein aktueller Funktionsnachweis |

Der Teillauf schließt Phase 0 nicht ab. Beim nächsten Lauf die VMs bewusst starten, die Prüfungen durchführen und auch Abweichungen dokumentieren. Für Phase 0 bleiben außerdem die erlaubte und verweigerte AD-Anmeldung sowie geeignete Rückfallverfahren für beide VMs zu klären.
