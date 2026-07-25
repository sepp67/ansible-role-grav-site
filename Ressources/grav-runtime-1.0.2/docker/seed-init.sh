#!/bin/sh
# seed-init.sh <seed-dir> <dest-dir> <label>
#
# Copies the contents of <seed-dir> into <dest-dir> only if <dest-dir> is
# currently empty. Never touches a destination that already has anything in
# it, and never deletes anything from it.
#
# State is read directly off each destination directory, not off a single
# shared flag file. That is deliberate: it lets an application image mount
# user/pages, user/accounts, user/data and user/images as separate volumes,
# each with its own independent lifecycle, without one directory's "already
# initialized" state leaking onto another's.

set -eu

SEED_DIR="$1"
DEST_DIR="$2"
LABEL="${3:-$DEST_DIR}"

log() {
  echo "[seed-init] $LABEL: $1"
}

if [ ! -d "$SEED_DIR" ]; then
  log "no seed at $SEED_DIR — skipping (nothing to do)."
  exit 0
fi

mkdir -p "$DEST_DIR"

if [ -n "$(ls -A "$DEST_DIR" 2>/dev/null)" ]; then
  log "destination $DEST_DIR already populated — leaving untouched."
  exit 0
fi

if [ -z "$(ls -A "$SEED_DIR" 2>/dev/null)" ]; then
  log "seed at $SEED_DIR is empty — nothing to copy."
  exit 0
fi

log "destination $DEST_DIR is empty — copying initial content from $SEED_DIR."
if ! cp -a "$SEED_DIR"/. "$DEST_DIR"/; then
  log "ERROR: failed to copy seed content from $SEED_DIR to $DEST_DIR."
  exit 1
fi

# cp -a preserves the seed's original ownership, whatever it was (root, a
# build-time UID, ...). Normalize it to www-data so PHP-FPM can read and
# write what was just seeded, regardless of how the seed was produced.
chown -R www-data:www-data "$DEST_DIR"
chmod -R u+rwX,g+rwX "$DEST_DIR"

log "initialized from seed."
