# Post-Install Test Plan

1. Create a Product and Price Book Entry (or use existing).
2. Create an Opportunity.
3. Add Opportunity Line Items.
4. Change Opportunity Stage to "Proposal/Quote".
   - A Quote is auto-created with copied address/contact details.
   - Quote Line Items are created from Opportunity Line Items.
5. Set Quote Status = "Accepted".
   - An Order is created.
   - Opportunity is set to "Closed Won".
   - Email is sent to Opportunity Owner.
   - (If ARES installed) In-app notification appears.
6. Update Order Status = "Shipped".
   - Opportunity remains Closed Won.

If notifications do not appear, confirm the ARES package is installed and users have access to the Platform Event.