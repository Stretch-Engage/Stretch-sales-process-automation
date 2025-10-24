# Installation

## 1) Prerequisites
- Salesforce org (Dev, Sandbox, or Production with admin)
- Salesforce CLI (SFDX)
- (Optional) ARES Notifications package

## 2) Install ARES (optional but recommended)
1. Open the AppExchange listing and click Get It Now.
2. Install in your target org with default options.
3. Ensure users can see the Notifications Lightning component and Platform Event.

## 3) Deploy the Source
Option A: Use the Deploy button in the README.  
Option B: CLI
```bash
sfdx auth:web:login -a StretchDemo
sfdx force:source:deploy -p force-app/main/default
```

## 4) Load Sample Data (optional)
```bash
sh scripts/import-sample-data.sh
```