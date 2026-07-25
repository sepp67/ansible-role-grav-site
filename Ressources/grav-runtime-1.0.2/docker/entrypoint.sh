#!/bin/sh
# entrypoint.sh — container PID 1.
#
# 1. Fixes ownership/permissions on the paths Grav writes to at runtime.
# 2. Initializes each persistent user/ subdirectory from /opt/grav-seed/,
#    independently, only if it is currently empty (docker/seed-init.sh).
# 3. Runs the optional admin bootstrap, as www-data, under a strict policy
#    (docker/bootstrap-admin.sh) — a partially configured bootstrap aborts
#    startup with a non-zero exit code.
# 4. Starts Nginx and PHP-FPM, supervises both: forwards SIGTERM/SIGINT to
#    both and waits for a clean shutdown, and if either exits on its own,
#    stops the other and exits non-zero.

set -eu

GRAV_ROOT="/var/www/html"
SEED_ROOT="/opt/grav-seed"

log() {
  echo "[entrypoint] $1"
}

# ---------------------------------------------------------------------------
# 1. Permissions — limited to the paths Grav/PHP-FPM actually write to, and
#    skipped when ownership is already correct (idempotent, no blanket
#    chown -R of the whole tree on every restart).
# ---------------------------------------------------------------------------

fix_permissions() {
  for path in \
    "$GRAV_ROOT/cache" \
    "$GRAV_ROOT/logs" \
    "$GRAV_ROOT/images" \
    "$GRAV_ROOT/assets" \
    "$GRAV_ROOT/user/accounts" \
    "$GRAV_ROOT/user/data" \
    "$GRAV_ROOT/user/pages" \
    "$GRAV_ROOT/user/images"
  do
    mkdir -p "$path"
    owner="$(stat -c '%u:%g' "$path")"
    if [ "$owner" != "82:82" ]; then
      log "fixing ownership of $path (was $owner)"
      chown -R www-data:www-data "$path"
      chmod -R u+rwX,g+rwX "$path"
    fi
  done
}

fix_permissions

# ---------------------------------------------------------------------------
# 2. Seed initialization — one independent call per persistent directory.
# ---------------------------------------------------------------------------

/seed-init.sh "$SEED_ROOT/pages"    "$GRAV_ROOT/user/pages"    "user/pages"    || exit 1
/seed-init.sh "$SEED_ROOT/accounts" "$GRAV_ROOT/user/accounts" "user/accounts" || exit 1
/seed-init.sh "$SEED_ROOT/data"     "$GRAV_ROOT/user/data"     "user/data"     || exit 1
/seed-init.sh "$SEED_ROOT/images"   "$GRAV_ROOT/user/images"   "user/images"   || exit 1

# ---------------------------------------------------------------------------
# 3. Optional PHP timezone (generic runtime setting, no site content).
# ---------------------------------------------------------------------------

if [ -n "${GRAV_TIMEZONE:-}" ]; then
  echo "date.timezone = ${GRAV_TIMEZONE}" > /usr/local/etc/php/conf.d/zz-timezone.ini
fi

# ---------------------------------------------------------------------------
# 4. Optional admin bootstrap — runs as www-data so it never creates
#    root-owned files. Aborts startup on a strict-policy violation.
# ---------------------------------------------------------------------------

set +e
su-exec www-data:www-data /bootstrap-admin.sh
BOOTSTRAP_STATUS=$?
set -e

if [ "$BOOTSTRAP_STATUS" -ne 0 ]; then
  log "ERROR: admin bootstrap failed (exit $BOOTSTRAP_STATUS) — aborting startup."
  exit "$BOOTSTRAP_STATUS"
fi

# ---------------------------------------------------------------------------
# 5. Start Nginx and PHP-FPM, supervised by this script (PID 1).
# ---------------------------------------------------------------------------

php-fpm -F &
PHP_PID=$!
log "php-fpm started (pid $PHP_PID)"

nginx -g "daemon off;" &
NGINX_PID=$!
log "nginx started (pid $NGINX_PID)"

shutting_down=0

on_term() {
  if [ "$shutting_down" -eq 1 ]; then
    return
  fi
  shutting_down=1
  log "signal received — stopping nginx and php-fpm..."
  kill -TERM "$NGINX_PID" 2>/dev/null || true
  kill -TERM "$PHP_PID" 2>/dev/null || true
  wait "$NGINX_PID" 2>/dev/null || true
  wait "$PHP_PID" 2>/dev/null || true
  log "stopped cleanly."
  exit 0
}
trap on_term TERM INT QUIT

while true; do
  if ! kill -0 "$NGINX_PID" 2>/dev/null; then
    log "ERROR: nginx (pid $NGINX_PID) exited unexpectedly — stopping php-fpm."
    kill -TERM "$PHP_PID" 2>/dev/null || true
    wait "$PHP_PID" 2>/dev/null || true
    exit 1
  fi
  if ! kill -0 "$PHP_PID" 2>/dev/null; then
    log "ERROR: php-fpm (pid $PHP_PID) exited unexpectedly — stopping nginx."
    kill -TERM "$NGINX_PID" 2>/dev/null || true
    wait "$NGINX_PID" 2>/dev/null || true
    exit 1
  fi
  sleep 1
done
