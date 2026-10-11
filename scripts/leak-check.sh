#!/usr/bin/env bash
# Prüft die zum Commit vorgemerkten Änderungen auf Inhalte, die nicht in ein öffentliches Repository gehören.
# Allgemeine Muster stehen hier. Persönliche Begriffe (eigene Domain, Mailadresse, Kontonamen)
# stehen in der lokalen, nicht versionierten Datei .git/leak-patterns.local (ein Muster pro Zeile, Regex).
set -u

mapfile -t patterns <<'PATTERNS'
-----BEGIN [A-Z ]*PRIVATE KEY-----
ghp_[A-Za-z0-9]{20,}
github_pat_[A-Za-z0-9_]{20,}
eyJ[A-Za-z0-9_-]{20,}\.[A-Za-z0-9_-]{10,}
[Pp]ass(wor[dt]|wd)[[:space:]]*[:=][[:space:]]*[^[:space:]<]
[Tt]oken[[:space:]]*[:=][[:space:]]*[A-Za-z0-9]{16,}
[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}
TunnelSecret
credentials-file
PATTERNS

local_file="$(git rev-parse --git-dir)/leak-patterns.local"
if [ -f "$local_file" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] && patterns+=("$line")
  done < "$local_file"
fi

added="$(git diff --cached -U0 --no-color -- . ':(exclude)scripts/leak-check.sh' | grep -E '^\+' | grep -vE '^\+\+\+' || true)"
status=0
for p in "${patterns[@]}"; do
  hits="$(printf '%s\n' "$added" | grep -E -e "$p" || true)"
  if [ -n "$hits" ]; then
    echo "Leak-Check: Muster '$p' gefunden in vorgemerkten Änderungen:" >&2
    printf '%s\n' "$hits" | head -5 | sed 's/^/    /' >&2
    status=1
  fi
done

if [ "$status" -ne 0 ]; then
  echo "Commit abgebrochen. Treffer prüfen. Bei einem Fehlalarm bewusst mit 'git commit --no-verify' fortfahren." >&2
fi
exit "$status"
