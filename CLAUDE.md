# Arbeitsregeln für dieses Repository

Dieses Repository ist die **öffentliche** Homelab-Dokumentation und wird von Personalern gelesen. Es gilt: lieber weniger, dafür belegt und sauber.

## Rollenverteilung

- **Dieses Repo** ist die Quelle für alles Technische und Öffentliche: Aufbau, Tests, Fehlersuche, Grenzen.
- **Die private Projektnotiz im Second Brain** (`04_Projekte/Homelab/Homelab.md`) ist die Quelle für Roadmap, Phasen, Abschlusskriterien und CV-Bezug. Technische Details werden dort nur verlinkt, nicht dupliziert.
- Es werden keine Commit-Hashes in die Projektnotiz geschrieben, nur Dateilinks.

## Ablauf bei jeder Änderung

1. Dokument in `docs/` ändern oder neu anlegen. Nummer fortlaufend, keine Nummer doppelt.
2. `README.md` aktualisieren: Doku-Liste, „Bisher umgesetzt“, „Nächste Schritte“.
3. Status in der Projektnotiz im Second Brain anpassen, erst nach Freigabe des Nutzers, da es ein eigenes Repository mit eigenen Regeln ist.
4. `scripts/sync-check.sh` ausführen und Hinweise abarbeiten.
5. Committen. Der Hook `scripts/leak-check.sh` läuft automatisch.
6. **Pushen nicht vergessen.** Das Online-Profil ist erst nach dem Push aktuell. Der Sync-Check meldet ungepushte Commits.

## Inhaltliche Regeln

- Nichts Privates: keine eigene Domain, keine Zugangsdaten, Tokens, Tunnel-Konfiguration, Mailadressen oder Kontonamen. Platzhalter wie `<eigene-domain>` verwenden.
- Nur dokumentieren, was geprüft wurde. Nicht Geprüftes als „nicht geprüft“ kennzeichnen, offene Ursachen als offen.
- Pro Prüfung: Frage, Befehl, worauf achten, Bedeutung. Fachbegriffe beim ersten Auftreten ausschreiben.
- Rolle von KI im jeweiligen Dokument ehrlich benennen.
- Stil: Ich-Form, sachlich, deutsch, ohne Werbesprache.

## Einrichtung nach dem Klonen

```bash
git config core.hooksPath .githooks
```

Persönliche Muster für den Leak-Check (eigene Domain, Mailadresse) stehen in `.git/leak-patterns.local`, ein Regex pro Zeile. Diese Datei wird nicht versioniert.

## Commits

Deutsche Commit-Nachrichten im Stil `docs: …`. Keine Co-Authored-By-Zeile.
