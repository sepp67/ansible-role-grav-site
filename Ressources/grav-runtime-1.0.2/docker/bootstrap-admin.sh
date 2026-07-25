#!/bin/sh
# bootstrap-admin.sh
#
# Optionally creates a Grav administrator account at container startup,
# using the official Grav CLI (`bin/plugin login new-user`). Runs as
# www-data (invoked via su-exec from entrypoint.sh), so it never creates
# root-owned files.
#
# Strict policy on GRAV_ADMIN_USER / GRAV_ADMIN_PASSWORD / GRAV_ADMIN_EMAIL:
#   - none set      -> bootstrap disabled, exit 0 (normal startup)
#   - all set       -> bootstrap runs
#   - partially set -> configuration error, exit 1 (blocks container startup)
#
# An existing account (user/accounts/<user>.yaml already present) is never
# overwritten: the script exits 0 without touching it.
#
# The password is never passed as a CLI argument (never visible in `ps aux`
# or /proc/<pid>/cmdline): it is fed to the CLI over stdin. No secret is
# ever written to logs.

set -eu

GRAV_ROOT="/var/www/html"
ACCOUNTS_DIR="$GRAV_ROOT/user/accounts"
LOGIN_PLUGIN_DIR="$GRAV_ROOT/user/plugins/login"

log() {
  echo "[bootstrap-admin] $1"
}

# ── 1. Strict validation of the three mandatory variables ──────────────────

set_count=0
for v in "${GRAV_ADMIN_USER:-}" "${GRAV_ADMIN_PASSWORD:-}" "${GRAV_ADMIN_EMAIL:-}"; do
  if [ -n "$v" ]; then
    set_count=$((set_count + 1))
  fi
done

if [ "$set_count" -eq 0 ]; then
  log "GRAV_ADMIN_USER / GRAV_ADMIN_PASSWORD / GRAV_ADMIN_EMAIL not set — admin bootstrap disabled."
  exit 0
fi

if [ "$set_count" -lt 3 ]; then
  log "ERROR: GRAV_ADMIN_USER, GRAV_ADMIN_PASSWORD and GRAV_ADMIN_EMAIL must be either all set or all unset."
  log "ERROR: partial admin bootstrap configuration — refusing to start."
  exit 1
fi

# ── 2. Never overwrite an existing account ──────────────────────────────────

ACCOUNT_FILE="$ACCOUNTS_DIR/${GRAV_ADMIN_USER}.yaml"

if [ -f "$ACCOUNT_FILE" ]; then
  log "Account '$GRAV_ADMIN_USER' already exists ($ACCOUNT_FILE) — skipping bootstrap."
  exit 0
fi

# ── 3. The official Grav CLI is required — no manual fallback ──────────────

if [ ! -d "$LOGIN_PLUGIN_DIR" ]; then
  log "ERROR: login plugin not found at $LOGIN_PLUGIN_DIR."
  log "ERROR: cannot bootstrap admin account without the official Grav CLI."
  exit 1
fi

# ── 4. Create the account via the official CLI, password fed over stdin ────

log "Bootstrapping admin account '$GRAV_ADMIN_USER' via bin/plugin login new-user..."

cd "$GRAV_ROOT"

# Real prompt order of `bin/plugin login new-user` (confirmed empirically,
# differs from what some versions of the documentation describe):
#   1. Username        2. Password           3. Repeat password
#   4. Email           5. Language (blank=default)
#   6. Permissions ([a] admin / [s] site / [b] admin+site)
#   7. Admin type ([admin] / [api] / [both])
#   8. Full name (REQUIRED — empty value fails validation)
#   9. Title (blank=default)                 10. State (blank=enabled)
#
# Permissions: always "b" (admin+site). Admin type: always "admin".
# Full name has no universally meaningful default, so it falls back to
# "Administrator" when GRAV_ADMIN_FULLNAME is not provided.
FULLNAME="${GRAV_ADMIN_FULLNAME:-Administrator}"
LANGUAGE="${GRAV_ADMIN_LANGUAGE:-}"
TITLE="${GRAV_ADMIN_TITLE:-}"

set +e
BOOTSTRAP_OUTPUT=$(
  printf '%s\n%s\n%s\n%s\n%s\nb\nadmin\n%s\n%s\n\n' \
    "$GRAV_ADMIN_USER" \
    "$GRAV_ADMIN_PASSWORD" \
    "$GRAV_ADMIN_PASSWORD" \
    "$GRAV_ADMIN_EMAIL" \
    "$LANGUAGE" \
    "$FULLNAME" \
    "$TITLE" \
  | bin/plugin login new-user 2>&1
)
BOOTSTRAP_STATUS=$?
set -e

# Never log raw output verbatim if it could contain the password — filter
# out any line that literally contains it, as defense in depth (the CLI
# itself does not echo it back).
SAFE_OUTPUT=$(printf '%s' "$BOOTSTRAP_OUTPUT" | grep -v -F "$GRAV_ADMIN_PASSWORD" || true)

if [ "$BOOTSTRAP_STATUS" -eq 0 ] && [ -f "$ACCOUNT_FILE" ]; then
  log "Admin account '$GRAV_ADMIN_USER' created successfully."
  exit 0
fi

log "ERROR: admin bootstrap did not complete successfully (exit code $BOOTSTRAP_STATUS)."
log "ERROR: CLI output (password redacted):"
printf '%s\n' "$SAFE_OUTPUT" | while IFS= read -r line; do
  log "  $line"
done
exit 1
