#!/usr/bin/env bash
set -euo pipefail

ORG_ALIAS="${1:-StretchDemo}"

echo ">>> Authenticating (web login)..."
sfdx auth:web:login -a "$ORG_ALIAS"

echo ">>> Pushing source..."
sfdx force:source:deploy -p force-app/main/default

echo ">>> Done."