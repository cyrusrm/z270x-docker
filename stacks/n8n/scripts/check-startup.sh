#!/usr/bin/env bash
#
# Background:
# During initial startup, the sandbox runner may register with the API before
# it is considered healthy and eligible to execute sandbox tasks.
# This startup delay can cause temporary sandbox initialization failures,
# particularly when bringing up the stack from a clean state.
#
# Run this script after starting the Docker Compose stack.
# Wait until all checks report PASS before using n8n Code nodes,
# to ensure the sandbox API and runner are ready.
#
# Run this from the directory containing your n8n compose.yaml / docker-compose.yml:
#   chmod +x check-n8n.sh
#   ./check-n8n.sh
#
# Optional:
#   ./check-n8n.sh --timeout 90
#
# This script is read-only: it checks services and endpoints but does not
# restart, stop, or modify containers or volumes.


set -uo pipefail

COMPOSE_FILE="/mnt/workspace/docker/stacks/n8n/compose.yaml"

TIMEOUT=90
INTERVAL=5
BASE_URL="${N8N_BASE_URL:-http://127.0.0.1:5678}"

while (($#)); do
  case "$1" in
    --timeout)
      if [[ $# -lt 2 || ! "$2" =~ ^[0-9]+$ ]]; then
        echo "Usage: $0 [--timeout SECONDS]" >&2
        exit 2
      fi
      TIMEOUT="$2"
      shift 2
      ;;
    -h|--help)
      sed -n '2,14p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Usage: $0 [--timeout SECONDS]" >&2
      exit 2
      ;;
  esac
done

PASS=0
FAIL=0
WARN=0

pass() { printf '  [PASS] %s\n' "$*"; PASS=$((PASS + 1)); }
fail() { printf '  [FAIL] %s\n' "$*"; FAIL=$((FAIL + 1)); }
warn() { printf '  [WARN] %s\n' "$*"; WARN=$((WARN + 1)); }
info() { printf '\n== %s ==\n' "$*"; }

if ! command -v docker >/dev/null 2>&1; then
  echo "ERROR: docker command not found." >&2
  exit 2
fi
if ! docker compose version >/dev/null 2>&1; then
  echo "ERROR: Docker Compose plugin is unavailable." >&2
  exit 2
fi
if ! docker compose config --quiet >/dev/null 2>&1; then
  echo "ERROR: No valid Compose project found in the current directory."
  echo "Run this script from the directory containing your Compose file."
  exit 2
fi

info "Compose services"
PS_OUTPUT="$(docker compose ps --format '{{.Service}}\t{{.State}}\t{{.Status}}' 2>/dev/null || true)"
if [[ -z "$PS_OUTPUT" ]]; then
  warn "No Compose containers are currently listed. Is the stack started?"
else
  printf '%s\n' "$PS_OUTPUT" | while IFS=$'\t' read -r service state status; do
    printf '  %-20s %-12s %s\n' "$service" "$state" "$status"
  done
fi

# Confirm that the expected service names exist in this Compose project.
SERVICES="$(docker compose config --services 2>/dev/null)"
for svc in n8n runners sandbox-api sandbox-runner-1; do
  if grep -Fxq "$svc" <<<"$SERVICES"; then
    pass "Compose service '$svc' is defined"
  else
    fail "Expected Compose service '$svc' was not found"
  fi
done

info "Container state"
for svc in n8n runners sandbox-api sandbox-runner-1; do
  if ! grep -Fxq "$svc" <<<"$SERVICES"; then
    continue
  fi
  state="$(docker compose ps --status running --services 2>/dev/null | grep -Fx "$svc" || true)"
  if [[ -n "$state" ]]; then
    pass "$svc container is running"
  else
    fail "$svc container is not running"
  fi
done

info "Sandbox API health"
if docker compose -f "$COMPOSE_FILE" exec -T sandbox-api sh -lc \
  'wget -qO- http://127.0.0.1:8080/healthz >/dev/null'; then
  pass "sandbox API /healthz responds successfully"
else
  fail "sandbox API /healthz did not respond successfully"
fi

info "Sandbox runner readiness"
if docker compose -f "$COMPOSE_FILE" exec -T sandbox-runner-1 sh -lc \
  'wget -qO- --no-check-certificate https://127.0.0.1:8080/readyz >/dev/null'; then
  pass "sandbox runner /readyz responds successfully"
else
  fail "sandbox runner /readyz did not respond successfully"
fi

info "Runner registration (wait up to ${TIMEOUT}s)"
deadline=$((SECONDS + TIMEOUT))
runner_ok=0
last_registry=""

while (( SECONDS <= deadline )); do
  # The API key is expanded inside the API container. Its value is never
  # printed or copied into this script's output.
  last_registry="$(docker compose -f "$COMPOSE_FILE" exec -T sandbox-api sh -lc \
    'wget -qO- --header="X-Api-Key: $SANDBOX_API_KEYS" http://127.0.0.1:8080/admin/runners' \
    2>/dev/null || true)"

  if grep -Eq '"healthy"[[:space:]]*:[[:space:]]*true' <<<"$last_registry" &&
     grep -Eq '"cordoned"[[:space:]]*:[[:space:]]*false' <<<"$last_registry"; then
    runner_ok=1
    break
  fi

  sleep "$INTERVAL"
done

if (( runner_ok )); then
  pass "sandbox runner is registered, healthy=true, cordoned=false"
else
  fail "runner did not become healthy and eligible within ${TIMEOUT}s"
  if [[ -n "$last_registry" ]]; then
    echo "  Registry response (API key omitted):"
    # Print only non-secret JSON response from the admin endpoint.
    printf '  %s\n' "$last_registry"
  else
    echo "  Could not retrieve the runner registry. Check sandbox-api logs/config."
  fi
fi

info "n8n health"
if command -v curl >/dev/null 2>&1; then
  if curl --silent --show-error --fail --max-time 5 "$BASE_URL/healthz" >/dev/null; then
    pass "n8n /healthz responds at $BASE_URL"
  else
    fail "n8n /healthz did not respond at $BASE_URL"
  fi
else
  warn "curl is not installed; skipped host-side n8n /healthz check"
fi

info "Recent sandbox logs (only shown if a check failed)"
if (( FAIL > 0 )); then
  echo "  --- sandbox-api ---"
  docker compose logs --since=5m --tail=40 sandbox-api 2>&1 || true
  echo "  --- sandbox-runner-1 ---"
  docker compose logs --since=5m --tail=40 sandbox-runner-1 2>&1 || true
fi

printf '\nSummary: %d PASS, %d FAIL, %d WARN\n' "$PASS" "$FAIL" "$WARN"
if (( FAIL > 0 )); then
  echo "Result: NOT READY — review the failed checks above."
  exit 1
fi

echo "Result: READY — the checked n8n and sandbox components are responding."
exit 0
