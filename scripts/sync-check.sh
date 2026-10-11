#!/usr/bin/env bash
# Vergleicht Repository, GitHub und die private Projektnotiz im Second Brain.
# Nur lesend. Aufruf: scripts/sync-check.sh [Pfad-zur-Homelab.md]
set -u

repo="$(git rev-parse --show-toplevel)"
vault_note="${1:-${HOMELAB_NOTE:-$HOME/Dokumente/FISI-Second-Brain/04_Projekte/Homelab/Homelab.md}}"
problems=0
warn() { echo "  ! $*"; problems=$((problems + 1)); }
ok()   { echo "  ok $*"; }

cd "$repo" || exit 2

echo "1. Repository gegen GitHub"
git fetch -q origin 2>/dev/null || warn "git fetch fehlgeschlagen (offline?)"
if [ -n "$(git status --porcelain)" ]; then warn "uncommittete Änderungen vorhanden"; else ok "Arbeitsverzeichnis sauber"; fi
ahead="$(git rev-list --count origin/main..HEAD 2>/dev/null || echo 0)"
behind="$(git rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"
[ "$ahead" -gt 0 ]  && warn "$ahead Commit(s) nicht gepusht (Profil online veraltet)"
[ "$behind" -gt 0 ] && warn "$behind Commit(s) auf GitHub, die lokal fehlen (git pull)"
[ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ] && ok "lokal und origin/main identisch"

echo "2. README gegen docs/"
for f in docs/*.md docs/troubleshooting/*.md; do
  [ -f "$f" ] || continue
  grep -qF "$f" README.md || warn "$f ist nicht in der README verlinkt"
done
grep -oE '\]\((docs/[^)#]+)\)' README.md | sed -E 's/^\]\(|\)$//g' | sort -u | while read -r link; do
  [ -f "$link" ] || echo "  ! README verlinkt fehlende Datei: $link"
done
numbers="$(ls docs/*.md 2>/dev/null | sed -E 's#docs/([0-9]+)-.*#\1#' | sort | uniq -d)"
[ -n "$numbers" ] && warn "doppelte Dokumentnummer(n): $numbers"

echo "3. Projektnotiz im Second Brain ($vault_note)"
if [ ! -f "$vault_note" ]; then
  warn "Notiz nicht gefunden"
else
  grep -oE 'docs/[A-Za-z0-9_./-]+\.md' "$vault_note" | sort -u | while read -r ref; do
    [ -f "$ref" ] || echo "  ! Notiz nennt $ref, die Datei fehlt im Repository"
  done
  for f in docs/*.md docs/troubleshooting/*.md; do
    [ -f "$f" ] || continue
    grep -qF "$f" "$vault_note" || warn "$f wird in der Notiz nicht erwähnt"
  done
  if grep -qE '[Cc]ommit `?[0-9a-f]{7,}`?' "$vault_note"; then
    warn "Notiz nennt Commit-Hashes; besser Dateilinks verwenden"
  fi
fi

echo
if [ "$problems" -eq 0 ]; then echo "Sync-Check: keine Abweichungen."; else echo "Sync-Check: $problems Hinweis(e)."; fi
exit 0
