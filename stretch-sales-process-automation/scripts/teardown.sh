#!/usr/bin/env bash
set -euo pipefail

ORG_ALIAS="${1:-StretchDemo}"

echo ">>> Deleting test data (if any)..."
# Add specific delete commands if you add IDs or SOQL filters.
echo "Done."