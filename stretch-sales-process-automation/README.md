<p align="center">
  <img src="docs/assets/logo.png" alt="Stretch Engage" width="260"/>
</p>

# stretch-sales-process-automation

Universal Salesforce sales process automation for demos and enablement.  
Unmanaged SFDX project with triggers and handlers to automate Opportunity → Quote → Order, with optional ARES in-app notifications.

> Internal Use Only – Stretch Consulting Proprietary

## 🚀 One‑Click Deploy

[![Deploy to Salesforce](https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png)](https://githubsfdeploy.herokuapp.com?owner=stretch-consulting&repo=stretch-sales-process-automation)

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

## Script for Demo 
[Scene 1: Opportunity Creation]

“Let’s start with a standard Opportunity in Salesforce.”

[click Opportunities tab]
[click New]

“I’ll create a new Opportunity called Example - Abc opportunity.
<img width="841" height="956" alt="image" src="https://github.com/user-attachments/assets/341756fb-4400-4f13-9542-4a75a281f1e6" />

I’ll associate it with an Account, Add products, and move the stage straight to Proposal/Quote.”
<img width="1691" height="694" alt="image" src="https://github.com/user-attachments/assets/a27b1570-6009-41dd-bb66-171ee48f8ff4" />


[fill fields, then click Save]

“Now watch what happens behind the scenes — as soon as I save, the automation kicks in.”

[Scene 2: Quote Automatically Created]
<img width="1690" height="653" alt="image" src="https://github.com/user-attachments/assets/a87fd344-2ad3-4ddf-8a70-19cddb5a19c1" />

[click Related tab on Opportunity]

“The system has automatically created a Quote linked to this Opportunity — no Flow, no manual creation.

This is powered by a clean Apex trigger that detects when an Opportunity enters the Proposal/Quote stage and generates a Quote automatically.”

[click the Quote record]

<img width="1684" height="954" alt="image" src="https://github.com/user-attachments/assets/109635f8-5a7a-4976-995e-3f3427e14c83" />


“The Quote has been pre-filled with all the products, pricing, and quantities from the Opportunity.
This keeps demos smooth and eliminates the need to re-enter data.”

[Scene 3: Quote Line Sync]

[click Quote Line Items tab or related list]
[edit a quantity — for example, change 5 to 10]
[click Save]
<img width="2505" height="403" alt="image" src="https://github.com/user-attachments/assets/183a75ee-06b2-4caa-a9a5-8c0b805000ee" />

“Now, let’s say the customer negotiates — maybe they want 10 units instead of 5.

When I save this change, the system automatically syncs the update back to the Opportunity Line Items.

That means both sales and finance always see the same numbers — completely in sync, no duplicate edits.”

[click back to Opportunity → Products]
<img width="761" height="439" alt="image" src="https://github.com/user-attachments/assets/0eb5c384-dd53-45c5-aa4c-46e65b360b09" />

“And here we can see the updated quantity reflected right away.”

[Scene 4: Quote PDF and Email]

[click back to Quote]
[click Generate PDF button]

“Once our Quote looks good, we can generate a professional PDF directly from Salesforce.

This uses the out-of-the-box Quote template — but it can easily be branded for any client demo.”
<img width="847" height="1095" alt="image" src="https://github.com/user-attachments/assets/bbfd1823-5ed8-4e26-988b-e0ad82331145" />

[show PDF preview]

“And from here, we can send it directly via email using the built-in Send Email action.”

[Click Quote to Accepted Status]
<img width="2502" height="397" alt="image" src="https://github.com/user-attachments/assets/32fe3496-444d-4e36-9f1b-eb444c1521dc" />

“That makes this part of the demo relatable — real data, real automation, real output.”

[Scene 5: Order Creation]


[click back to Opportunity]
[change Stage → Closed Won]
[click Save]
<img width="2532" height="217" alt="image" src="https://github.com/user-attachments/assets/bcb238ac-63b6-4ee8-9e8e-30636b308bb2" />

“Now, when we close the deal, the final piece of automation runs.

The system automatically creates an Order from the Quote, carrying all the details forward.”
<img width="1655" height="796" alt="image" src="https://github.com/user-attachments/assets/ae88e27e-b033-481d-9c1f-dec341509ad0" />
[click Related tab → show new Order record]

“That’s the entire process — Opportunity, Quote, and Order — handled automatically with no manual steps.

It’s clean, reusable, and perfect for fast client demos.”

[Scene 6: ARES In-App Notifications (Optional)]

[open Notifications Bell in Salesforce if configured]

“If ARES Notifications are installed, you’ll also see in-app alerts each time a Quote or Order is created.

This gives instant feedback to the user — they can see that automation has completed without leaving the page.”

<img width="432" height="166" alt="image" src="https://github.com/user-attachments/assets/e37b3faa-89df-4e9c-a78e-dafca219926d" />

“These notifications add polish to the demo and make the automation feel alive.”
