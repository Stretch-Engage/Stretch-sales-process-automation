<p align="center">
  <img src="docs/assets/logo.png" alt="Stretch Engage" width="260"/>
</p>

# stretch-sales-process-automation

Universal Salesforce sales process automation for demos and enablement.  
Unmanaged SFDX project with triggers and handlers to automate Opportunity → Quote → Order, with optional ARES in-app notifications.

> Internal Use Only – Stretch Consulting Proprietary

## 🚀 One‑Click Deploy

[![Deploy to Salesforce](https://githubsfdeploy.herokuapp.com/assets/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=stretch-consulting&repo=stretch-sales-process-automation)

Or deploy via CLI:

```bash
sfdx auth:web:login -a StretchDemo
sfdx force:source:deploy -p force-app/main/default
```

## 🔗 Prerequisite (ARES Notifications)
Install ARES Notifications from AppExchange before testing notifications:
https://appexchange.salesforce.com/appxListingDetail?listingId=a0N4V00000HPxzPUAT

## 📖 Docs
- docs/installation.md
- docs/post-install.md
- docs/troubleshooting.md
