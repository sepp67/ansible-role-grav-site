#!/bin/sh
# healthcheck.sh — used by the Dockerfile HEALTHCHECK instruction.
#
# Hits /healthz, which goes through Nginx and PHP-FPM but not through Grav's
# own front controller or any site content — it proves the two runtime
# processes are alive and wired together correctly, independently of any
# particular Grav site. Exits 0 if healthy, 1 otherwise.

set -eu

if curl -fsS -o /dev/null --max-time 2 "http://127.0.0.1/healthz"; then
  exit 0
fi

exit 1
