# SSH-Zugriff auf srv-linux01

Für die Administration von `srv-linux01` wird SSH verwendet.

Nachdem die grundlegende Anmeldung per Benutzerpasswort getestet worden war, wurde zusätzlich eine eigene Key-basierte Authentifizierung für das Homelab eingerichtet.

Dieser lokale administrative Zugang blieb nach der Active-Directory-Integration als Rückfallmöglichkeit erhalten und wurde erneut getestet.

## Ausgangssituation

SSH-Verbindungen vom Pop!_OS-Host zur VM waren bereits möglich.

Verbindung:

- Client: Pop!_OS-Host
- Server: `srv-linux01`
- Serverkonto: lokales administratives Benutzerkonto
- aktuelle Server-IP: `192.168.122.20`
- SSH-Server: OpenSSH

Bei der ursprünglichen SSH-Einrichtung verwendete die VM noch die per DHCP vergebene Adresse `192.168.122.156`. Die folgenden historischen Befehle behalten deshalb diese damals verwendete Adresse.

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

Der öffentliche Schlüssel wurde während der ursprünglichen Einrichtung mit `ssh-copy-id` auf `srv-linux01` übertragen.

Im folgenden historischen Beispiel ist `BENUTZERNAME` ein Platzhalter für das damalige lokale Benutzerkonto. Der Befehl ist ohne Ersetzen dieses Platzhalters nicht direkt verwendbar.

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_homelab.pub BENUTZERNAME@192.168.122.156
```

Auf dem Server wird der Public Key für das jeweilige lokale Benutzerkonto unter

```text
~/.ssh/authorized_keys
```

gespeichert.

Nach der Übertragung wurde geprüft, dass genau ein Schlüssel in der Datei vorhanden war.

Die Datei besaß die Berechtigung:

```text
-rw-------
```

entsprechend `600`.

## Key-basierte Anmeldung testen

Die Anmeldung wurde während der ursprünglichen Einrichtung ausdrücklich mit dem neuen privaten Schlüssel getestet.

Auch hier ist `BENUTZERNAME` ein Platzhalter, der vor einer eigenen Verwendung ersetzt werden müsste:

```bash
ssh -i ~/.ssh/id_ed25519_homelab BENUTZERNAME@192.168.122.156
```

Die Verbindung war erfolgreich. Damit wurde bestätigt, dass die Authentifizierung mit dem neuen Schlüsselpaar funktionierte.

## SSH-Client-Konfiguration

Damit IP-Adresse, Benutzername und Schlüssel nicht bei jeder Verbindung angegeben werden müssen, wurde auf dem Pop!_OS-Host eine SSH-Client-Konfiguration angelegt:

```text
~/.ssh/config
```

Die aktuelle Konfiguration muss auf die feste Adresse `192.168.122.20` zeigen.

In der öffentlichen Darstellung ersetzt `BENUTZERNAME` den tatsächlichen lokalen Benutzernamen. Der folgende Ausschnitt ist deshalb keine direkt kopierbare Konfiguration:

```text
Host srv-linux01
    HostName 192.168.122.20
    User BENUTZERNAME
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

Beim Einrichten der SSH-Client-Konfiguration trat auf dem Host ein Berechtigungsproblem auf. Die Fehlersuche und Behebung ist unter [Fehlersuche bei Home-Verzeichnisrechten](troubleshooting/01-home-directory-permissions.md) dokumentiert.

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
