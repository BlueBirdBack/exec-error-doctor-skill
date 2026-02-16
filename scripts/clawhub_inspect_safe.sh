#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  clawhub_inspect_safe.sh <slug> [max_retries] [sleep_seconds]

Behavior:
- Tries `clawhub inspect <slug> --json` with retry/backoff.
- Treats temporary states as transient:
  - hidden while security scan pending
  - skill not found right after publish/index lag
- If inspect still fails but web page exists at /skills/<slug>, exits 0 with mitigation note.
- If both inspect and web page fail, exits non-zero.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

SLUG="$1"
MAX_RETRIES="${2:-12}"
SLEEP_SECONDS="${3:-10}"
URL="https://clawhub.ai/skills/${SLUG}"

if ! command -v clawhub >/dev/null 2>&1; then
  echo "ERROR: clawhub CLI not found" >&2
  exit 3
fi

last_err=""
for ((i=1; i<=MAX_RETRIES; i++)); do
  set +e
  out=$(clawhub inspect "$SLUG" --json 2>&1)
  ec=$?
  set -e

  if [[ $ec -eq 0 ]]; then
    echo "$out"
    echo "OK: inspect succeeded for ${SLUG}."
    exit 0
  fi

  last_err="$out"
  if grep -qiE 'hidden while security scan is pending|skill not found|fetching skill' <<<"$out"; then
    echo "Attempt ${i}/${MAX_RETRIES}: inspect not ready (${SLUG}). Waiting ${SLEEP_SECONDS}s..." >&2
    sleep "$SLEEP_SECONDS"
    continue
  fi

  echo "$out" >&2
  exit $ec
done

# Fallback mitigation: if web page exists, treat as mitigated transient inconsistency.
set +e
http_code=$(curl -sS -o /tmp/clawhub_inspect_safe_${SLUG}.html -w '%{http_code}' "$URL")
ec=$?
set -e

if [[ $ec -eq 0 && "$http_code" == "200" ]]; then
  echo "WARN: inspect still failing after retries, but web page exists: $URL" >&2
  echo "MITIGATION: likely API/indexing inconsistency. Use web URL for validation and retry inspect later." >&2
  echo "LAST_ERROR:" >&2
  echo "$last_err" >&2
  exit 0
fi

echo "ERROR: inspect failed and web page is unavailable ($URL, http=${http_code:-n/a})." >&2
echo "LAST_ERROR:" >&2
echo "$last_err" >&2
exit 4
