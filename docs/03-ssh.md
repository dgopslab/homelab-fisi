# SSH-Zugriff auf srv-linux01

Für die Administration von `srv-linux01` wird SSH verwendet.

Nachdem die grundlegende Anmeldung per Benutzerpasswort getestet wurde, wurde zusätzlich eine eigene Key-basierte Authentifizierung für das Homelab eingerichtet.

## Ausgangssituation

SSH-Verbindungen vom Pop!_OS-Host zur VM waren bereits möglich.

Verbindung:

* Client: Pop!_OS-Host
* Benutzer auf dem Client: `jekkyl`
* Server: `srv-linux01`
* Benutzer auf dem Server: `daniel`
* aktuelle Server-IP: `192.168.122.156`
* SSH-Server: OpenSSH

Die IP-Adresse wird derzeit über DHCP vergeben und kann sich zukünftig ändern.

## Eigener SSH-Schlüssel für das Homelab

Der bereits für GitHub verwendete SSH-Schlüssel wird nicht für die Serveradministration wiederverwendet.

Stattdessen wurde ein eigenes Schlüsselpaar erstellt:

```text
~/.ssh/id_ed25519_homelab
~/.ssh/id_ed25519_homelab.pub
```

Der Schlüssel wurde mit Ed25519 erstellt und durch eine Passphrase geschützt.

Dabei gilt:

* `id_ed25519_homelab` ist der private Schlüssel und bleibt auf dem Client.
* `id_ed25519_homelab.pub` ist der öffentliche Schlüssel und darf auf Zielsystemen hinterlegt werden.

Der private Schlüssel wird nicht auf den Server übertragen.

## Public Key auf den Server übertragen

Der öffentliche Schlüssel wurde mit `ssh-copy-id` auf `srv-linux01` übertragen:

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_homelab.pub daniel@192.168.122.156
```

Auf dem Server wird der Public Key für den Benutzer `daniel` unter

```text
~/.ssh/authorized_keys
```

gespeichert.

Nach der Übertragung wurde geprüft, dass genau ein Schlüssel in der Datei vorhanden ist.

Die Datei besitzt die Berechtigung:

```text
-rw-------
```

entsprechend `600`.

## Key-basierte Anmeldung testen

Die Anmeldung wurde zunächst ausdrücklich mit dem neuen privaten Schlüssel getestet:

```bash
ssh -i ~/.ssh/id_ed25519_homelab daniel@192.168.122.156
```

Die Verbindung war erfolgreich.

Damit wurde bestätigt, dass die Authentifizierung mit dem neuen Schlüsselpaar funktioniert.

## SSH-Client-Konfiguration

Damit IP-Adresse, Benutzername und Schlüssel nicht bei jeder Verbindung angegeben werden müssen, wurde auf dem Pop!_OS-Host eine SSH-Client-Konfiguration angelegt:

```text
~/.ssh/config
```

Konfiguration:

```text
Host srv-linux01
    HostName 192.168.122.156
    User daniel
    IdentityFile ~/.ssh/id_ed25519_homelab
    IdentitiesOnly yes
```

Die Datei besitzt die Berechtigung:

```text
-rw-------
```

entsprechend `600`.

Anschließend reicht für die Verbindung:

```bash
ssh srv-linux01
```

Der Test war erfolgreich.

Beim Einrichten der SSH-Client-Konfiguration trat auf dem Host ein Berechtigungsproblem auf. Die Fehlersuche und Behebung ist unter 01-home-directory-permissions.md dokumentiert.

## Vereinfachter Ablauf der Authentifizierung

```text
Pop!_OS-Host
│
├── privater Schlüssel
│   ~/.ssh/id_ed25519_homelab
│
│ SSH-Verbindung
▼
srv-linux01
│
└── öffentlicher Schlüssel
    ~/.ssh/authorized_keys
```

Der private Schlüssel verlässt den Client nicht.

## Sicherheitsstand

Aktuell funktioniert die Key-basierte Authentifizierung.

Die Passwortauthentifizierung wurde noch nicht deaktiviert. Diese Änderung soll erst erfolgen, nachdem die effektive SSH-Serverkonfiguration geprüft und die Key-Anmeldung nochmals über eine separate Sitzung getestet wurde.

## Nächste Schritte

* effektive SSH-Serverkonfiguration prüfen
* erlaubte Authentifizierungsmethoden untersuchen
* Key-Login über eine zweite Sitzung testen
* Passwortauthentifizierung gegebenenfalls deaktivieren
* SSH-Konfiguration erneut testen
