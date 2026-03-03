#!/bin/bash
# Run full deploy from repo root (this script just redirects)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_INSTALL="$(cd "$SCRIPT_DIR/../.." && pwd)/install.sh"
if [ ! -f "$ROOT_INSTALL" ]; then
  echo "Run from repo root: bash install.sh"
  echo "Or: bash /var/www/miniapp/install.sh"
  exit 1
fi
exec bash "$ROOT_INSTALL"
