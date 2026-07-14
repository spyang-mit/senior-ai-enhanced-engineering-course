#!/usr/bin/env bash
#
# backup.sh — archive a directory and ship it to a backup host over ssh.
#
# This is the "audited" reference for Module 1. Read it line by line; every
# choice here is defensive on purpose. Inside the sandbox you can run it as-is:
#
#   ./backup.sh ~/playground/projects backup@localhost:~/backups
#
# Usage:
#   ./backup.sh <source-dir> <user@host:remote-dir>
#
# It: (1) tars + gzips <source-dir>, (2) scp's the archive to the remote,
# (3) checks the exit code after each step and reports honestly.

# Stop on the first error (-e), treat unset variables as errors (-u), and make
# a failure anywhere in a pipeline fail the whole pipeline (-o pipefail).
# Without this a script happily continues after a step has already failed.
set -euo pipefail

# --- arguments --------------------------------------------------------------
# Quote every expansion. If $1 is empty or contains spaces, quoting is what
# keeps a command from silently doing the wrong (or destructive) thing.
if [ "$#" -ne 2 ]; then
  echo "usage: $0 <source-dir> <user@host:remote-dir>" >&2
  exit 2
fi

SRC="$1"          # e.g. /home/dev/playground/projects
DEST="$2"         # e.g. backup@localhost:~/backups

# Fail early with a clear message if the source isn't a real directory,
# rather than letting tar emit something cryptic later.
if [ ! -d "$SRC" ]; then
  echo "error: source directory does not exist: $SRC" >&2
  exit 1
fi

# --- build the archive ------------------------------------------------------
# A timestamped name so repeated backups don't overwrite each other.
STAMP="$(date +%Y%m%d-%H%M%S)"
BASE="$(basename "$SRC")"
ARCHIVE="/tmp/backup-${BASE}-${STAMP}.tar.gz"

echo "Archiving $SRC -> $ARCHIVE"
# -C changes into the parent so the archive holds "projects/..." not the full
# absolute path. czf = create, gzip, file.
if tar czf "$ARCHIVE" -C "$(dirname "$SRC")" "$BASE"; then
  echo "  tar succeeded ($(du -h "$ARCHIVE" | cut -f1))"
else
  echo "error: tar failed with exit code $?" >&2
  exit 1
fi

# --- ship it ----------------------------------------------------------------
echo "Copying $ARCHIVE -> $DEST"
if scp "$ARCHIVE" "$DEST"; then
  echo "  scp succeeded"
else
  code=$?
  echo "error: scp failed with exit code $code" >&2
  # Clean up the local archive so a failed run doesn't litter /tmp.
  rm -f "$ARCHIVE"
  exit "$code"
fi

# --- done -------------------------------------------------------------------
rm -f "$ARCHIVE"   # local copy no longer needed; the backup is on the remote
echo "Backup complete: ${BASE} shipped to ${DEST}"
exit 0
