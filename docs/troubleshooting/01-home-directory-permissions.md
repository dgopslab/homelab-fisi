# Troubleshooting: Zugriff auf ~/.ssh nicht möglich

## Problem

Beim Einrichten der SSH-Client-Konfiguration auf dem Pop!_OS-Host schlugen Zugriffe auf `~/.ssh` mit einer Berechtigungsfehlermeldung fehl.

Beispiel:

In den folgenden Ausgaben ersetzt `BENUTZERNAME` den tatsächlichen lokalen Benutzernamen.

```text
Zugriff auf '/home/BENUTZERNAME/.ssh/config' nicht möglich:
Keine Berechtigung
```

Da das Verzeichnis zum eigenen Benutzer gehört, wurde nicht direkt mit `sudo` weitergearbeitet. Stattdessen wurden zunächst Eigentümer und Dateirechte untersucht.

## Analyse

Zuerst wurde das Home-Verzeichnis ermittelt:

```bash
echo "$HOME"
```

Ergebnis:

```text
/home/BENUTZERNAME
```

Anschließend wurden die Rechte des Home- und SSH-Verzeichnisses geprüft:

```bash
ls -ld "$HOME" "$HOME/.ssh"
```

Für das Home-Verzeichnis wurde festgestellt:

```text
drw------- ... /home/BENUTZERNAME
```

Dem Besitzer fehlte damit das Execute-Bit `x`.

Bei einem Verzeichnis bedeutet `x`, dass das Verzeichnis betreten beziehungsweise durchlaufen werden darf.

Obwohl der Benutzer Eigentümer des Home-Verzeichnisses war, konnte deshalb nicht auf darunterliegende Pfade wie

```text
/home/BENUTZERNAME/.ssh
```

zugegriffen werden.

## Behebung

Die Berechtigung des Home-Verzeichnisses wurde auf `700` gesetzt:

```bash
chmod 700 "$HOME"
```

Danach ergab die Kontrolle:

```text
drwx------ ... /home/BENUTZERNAME
```

Der Zugriff auf `~/.ssh` war anschließend wieder möglich.

## SSH-Config prüfen

Bei der anschließenden Kontrolle wurde außerdem festgestellt, dass die neu angelegte SSH-Client-Konfiguration zunächst die Berechtigung `664` besaß:

```text
-rw-rw-r--
```

Die Datei wurde deshalb auf `600` gesetzt:

```bash
chmod 600 ~/.ssh/config
```

Ergebnis:

```text
-rw-------
```

## Kontrolle

Nach der Korrektur funktionierte die konfigurierte SSH-Verbindung:

```bash
ssh srv-linux01
```

Die Anmeldung auf `srv-linux01` war erfolgreich.

## Erkenntnis

Eine Meldung wie `Permission denied` bedeutet nicht automatisch, dass ein Befehl mit `sudo` ausgeführt werden sollte.

In diesem Fall führte die systematische Prüfung von

1. Benutzer
2. Eigentümer
3. Verzeichnisrechten
4. Datei-Rechten

zur eigentlichen Ursache.

Bei Verzeichnissen muss besonders berücksichtigt werden, dass das Execute-Bit `x` das Betreten beziehungsweise Durchlaufen des Verzeichnisses erlaubt.

Warum das Execute-Bit des Home-Verzeichnisses zuvor fehlte, wurde im Rahmen dieser Fehlersuche nicht festgestellt.
