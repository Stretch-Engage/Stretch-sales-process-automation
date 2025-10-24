#!/usr/bin/env bash
set -euo pipefail

ORG_ALIAS="${1:-StretchDemo}"

echo ">>> Importing sample Accounts..."
sfdx force:data:tree:import -p data/plan.json -u "$ORG_ALIAS" || true

echo "Done."