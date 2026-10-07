# Fernzugriff über Cloudflare Tunnel und Cloudflare Access

## Ausgangslage

Ich möchte von meinem Schulungsstandort aus auf das Homelab zugreifen. Auf dem dortigen Leihlaptop habe ich keine Administratorrechte und kann keine Software installieren. Tailscale war auf dem Homelab-Host eingerichtet und funktionierte zu Hause, auch mit dem Leihlaptop, und über Mobilfunk. Am Schulungsstandort kam mit dem Leihlaptop keine Verbindung zustande. DNS-Auflösung und eine TCP-Verbindung zu `login.tailscale.com` auf Port 443 waren möglich. Die Ursache habe ich nicht gefunden.

## Randbedingungen

Diese Vorgaben standen vor der Auswahl der Lösung fest:

- Kein öffentliches Portforwarding für SSH oder RDP.
- Keine Umgehung von Netzfiltern am Schulungsstandort.
- Kein Smartphone-Hotspot als Dauerlösung.
- Keine Zugangsdaten oder Schlüssel in GitHub.
- Keine Installation auf dem Leihlaptop. Ein Browser muss reichen.

## Alternativen und Entscheidung

| Variante | Bewertung |
|---|---|
| Portfreigabe am Router | Verworfen. Ein aus dem Internet erreichbarer SSH- oder RDP-Dienst widerspricht den Vorgaben. |
| Tailscale | Am Schulungsstandort nicht nutzbar, Ursache offen. |
| Smartphone-Hotspot | Als Notlösung denkbar, als Dauerlösung ausgeschlossen. |
| Cloudflare Tunnel mit Cloudflare Access | Gewählt. Der Host baut die Verbindung von innen nach außen auf, deshalb muss kein eingehender Port geöffnet werden. Anfragen erreichen den Host über diese bestehende Verbindung. Der Zugriff läuft im Browser. Nachteil: Der Zugang hängt an einem Drittanbieter und braucht eine eigene Domain. |

Ich habe Cloudflare Tunnel mit Cloudflare Access gewählt, weil es meine Vorgaben erfüllt: kein eingehender Port, Zugriff im Browser und keine Installation auf dem Leihlaptop. Tailscale hatte ich vorher getestet und es scheiterte am Standort.

## Aufbau

```text
Browser → Cloudflare Access (Anmeldung) → Cloudflare Tunnel → cloudflared auf dem Pop!_OS-Host
                                                               ├─ Cockpit (localhost:9090)  → Host und VM-Konsolen
                                                               └─ geplant: private Route (nur DC01) → RDP im Browser
```

- `cloudflared` läuft als systemd-Dienst auf dem Pop!_OS-Host und hält vier Verbindungen zu Cloudflare.
- Cockpit ist die Weboberfläche zur Verwaltung des Hosts und der VMs. Sie ist über einen eigenen Hostnamen unter `<eigene-domain>` veröffentlicht.
- Die VMs erreiche ich bisher über die VM-Konsole in Cockpit. Für `DC01` ist zusätzlich RDP im Browser geplant, weil Darstellung und Arbeit am Server damit einfacher sind. Dafür sind eine private Route nur zu dieser einen Adresse und ein Access-Target vorgesehen.
- Der Zugang zu Cockpit ist durch Cloudflare Access geschützt. Eine Policy lässt nur eine einzige E-Mail-Adresse zu. Die Anmeldung erfolgt per Einmal-PIN, die Sitzung dauert acht Stunden.

## Umsetzung

1. **Domain zu Cloudflare umziehen.** Die Nameserver der Domain habe ich beim Registrar auf Cloudflare umgestellt. Ob die Delegation wirksam ist, habe ich direkt bei der DENIC abgefragt, weil der lokale Resolver zwischengespeicherte Antworten liefert.
2. **Tunnel prüfen.** Dienststatus und Tunnelstatus im Dashboard kontrolliert.
3. **Zugangsschutz zuerst.** Login-Methode, Policy und Access-Anwendung habe ich angelegt, bevor ein Hostname veröffentlicht wurde. Dadurch war Cockpit zu keinem Zeitpunkt ohne Anmeldung erreichbar.
4. **Cockpit veröffentlichen.** Der Tunnel leitet auf `https://localhost:9090`. Cockpit verwendet ein selbstsigniertes Zertifikat, deshalb ist die Zertifikatsprüfung für diese lokale Verbindung ausgeschaltet.
5. **VM-Zugriff über die Cockpit-Konsole.** Dafür habe ich die VM-Anzeige von Spice auf VNC umgestellt. Die VMs öffne ich seitdem in Cockpit über die Konsole.

## Zugriffskontrolle

- Zugang hat nur eine freigegebene E-Mail-Adresse. Alle anderen Anfragen werden abgewiesen.
- Die Anmeldung erfolgt per Einmal-PIN an diese Adresse. Das ist keine Mehrfaktor-Anmeldung. Die Sicherheit hängt am E-Mail-Postfach. Für dieses Postfach ist eine Zwei-Faktor-Anmeldung aktiv.
- Danach folgt die normale Anmeldung an Cockpit mit einem Systemkonto. Administrative Rechte in Cockpit schalte ich nur für Arbeiten an den VMs ein.

## Tests

| Datum | Netz | Ergebnis |
|---|---|---|
| 06.10.2026 | Schulungsstandort (Netz mit Webfilter) | Zugriff auf den Pop!_OS-Host und alle VMs erfolgreich. Die VMs habe ich über die Cockpit-Konsole geöffnet. |
| 05.10.2026 | Heimnetz, Browser im privaten Fenster | Anmeldung und Zugriff auf Cockpit erfolgreich. |

## Fehlerdiagnose: Anmeldeschleife in Cockpit

**Symptom:** Nach der PIN-Anmeldung nahm Cockpit meine Zugangsdaten an und zeigte danach wieder die Anmeldeseite.

**Vorgehen:**

1. Anmeldung direkt am Host über `localhost:9090` getestet. Sie funktionierte, damit lag der Fehler nicht an den Zugangsdaten.
2. Das Journal von Cockpit mit `journalctl` ausgewertet.
3. Die Antwort-Header über den Tunnel mit `cloudflared access curl` abgerufen und dabei Cookie-Werte ausgeblendet. Die Suche in den Browser-Entwicklerwerkzeugen habe ich dafür abgebrochen.

**Ursache:** Ein Cookie-Problem beim Weiterleiten von der Cloudflare-Anmeldeseite zu Cockpit. Den genauen Mechanismus habe ich nicht abschließend geklärt.

**Umgehung:** Nach der PIN-Anmeldung die Adresse erneut mit der Eingabetaste aufrufen, statt auf die automatische Weiterleitung zu warten. Eine dauerhafte Lösung habe ich nicht umgesetzt.

## Grenzen und Sicherheitsbewertung

- Der Zugang hängt an einem Cloudflare-Konto und an einem E-Mail-Postfach. Fällt eines von beiden aus oder wird übernommen, ist der Zugang betroffen.
- Der Zugang funktioniert nur, solange der Host läuft. Dafür habe ich den Ruhezustand abgeschaltet und geprüft, dass die für den Tunnel benötigten Dienste beim Start automatisch starten.
- Zwischen `cloudflared` und Cockpit ist die Zertifikatsprüfung ausgeschaltet. Die Verbindung bleibt lokal auf dem Host.
- Es gibt keine Überwachung und keine Benachrichtigung bei Ausfall des Tunnels.

**Notfall-Abschaltung:** Noch nicht beschrieben und nicht getestet.

## Was ich nicht gemacht habe

- Keine Härtung nach professionellem Standard und keine Auswertung der Cloudflare-Protokolle.
- Kein RDP-Zugriff. Die VMs erreiche ich über die Cockpit-Konsole.
- Keine Mehrfaktor-Anmeldung bei Cloudflare Access selbst und keine Geräteprüfung.
- Keine dauerhafte Lösung für das Cookie-Problem.

## Nächste Schritte

- RDP im Browser für `DC01` einrichten: private Route nur zu dieser einen Adresse, Access-Target, DNS-Eintrag und RDP-Anwendung. Die Route bleibt auf eine Adresse beschränkt, damit über den Zugang nicht das gesamte VM-Netz erreichbar wird.
- Notfall-Abschaltung testen und dokumentieren.
- Tunnel-Ausfall überwachen (spätere Phase der Roadmap).

## Einsatz von KI

Ich nutze KI als Werkzeug und Sparringspartner, vor allem für Recherche, den Vergleich von Alternativen und die Fehlersuche. Der Aufbau folgte einer KI-gestützten Schritt-für-Schritt-Anleitung, die ich selbst am Host und im Dashboard ausgeführt habe. Ob die Lösung zu meinen Vorgaben passt, habe ich anhand eines YouTube-Tutorials zum Tunnel-Aufbau und weiterer Online-Recherche geprüft. Den Zugriff habe ich am Schulungsstandort selbst getestet. Die Entscheidung habe ich getroffen.
