/**
 * @author Sidharrth Nandhakumar
 * @date 2025-10-17
 * @description Handles actions when a Quote is accepted:
 *  - Closes related Opportunities as Closed Won
 *  - Creates Orders and copies Quote Line Items to Order Items
 *  - Sends email to Opportunity Owner
 *  - Publishes ARES notifications (if package installed)
 */
public class QuoteTriggerHandler {

    public static void handleAcceptedQuotes(List<Quote> newQuotes, Map<Id, Quote> oldMap) {
        if (newQuotes == null || newQuotes.isEmpty()) return;

        List<Quote> acceptedQuotes = new List<Quote>();
        // 1) Collect newly-accepted Quotes
        for (Quote q : newQuotes) {
            Quote oldQ = oldMap != null ? oldMap.get(q.Id) : null;
            if (q.Status == 'Accepted' && (oldQ == null || oldQ.Status != 'Accepted')) {
                acceptedQuotes.add(q);
            }
        }
        if (acceptedQuotes.isEmpty()) return;

        // 2) Close related Opportunities as Closed Won (bulk)
        Set<Id> oppIdsToClose = new Set<Id>();
        for (Quote q : [
            SELECT Id, OpportunityId
            FROM Quote
            WHERE Id IN :acceptedQuotes AND OpportunityId != null
        ]) {
            oppIdsToClose.add(q.OpportunityId);
        }
        if (!oppIdsToClose.isEmpty()) {
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Id oid : oppIdsToClose) {
                oppsToUpdate.add(new Opportunity(Id = oid, StageName = 'Closed Won'));
            }
            if (!oppsToUpdate.isEmpty()) update oppsToUpdate;
        }

        // 3) Create Orders for the accepted quotes (bulk)
        List<Order> ordersToInsert = new List<Order>();
        for (Quote q : acceptedQuotes) {
            ordersToInsert.add(new Order(
                Name = q.Name + ' Order',
                AccountId = q.AccountId,
                ContractId = q.ContractId,
                Pricebook2Id = q.Pricebook2Id,
                EffectiveDate = System.today(),
                EndDate = q.ExpirationDate,
                Description = q.Description,
                OwnerId = q.OwnerId,
                Status = 'Draft',
                QuoteId = q.Id,
                BillingStreet = q.BillingStreet,
                BillingCity = q.BillingCity,
                BillingState = q.BillingState,
                BillingPostalCode = q.BillingPostalCode,
                BillingCountry = q.BillingCountry,
                ShippingStreet = q.ShippingStreet,
                ShippingCity = q.ShippingCity,
                ShippingState = q.ShippingState,
                ShippingPostalCode = q.ShippingPostalCode,
                ShippingCountry = q.ShippingCountry
            ));
        }
        if (!ordersToInsert.isEmpty()) insert ordersToInsert;

        // 4) Map Quote -> Order
        Map<Id, Id> quoteToOrderMap = new Map<Id, Id>();
        // Note: insert order returns Ids maintaining list order
        Map<String, Order> orderByName = new Map<String, Order>();
        for (Order o : [SELECT Id, Name, QuoteId FROM Order WHERE QuoteId IN :new Map<Id, Quote>(acceptedQuotes).keySet()]) {
            if (o.QuoteId != null) quoteToOrderMap.put(o.QuoteId, o.Id);
        }

        // 5) Copy Quote Line Items -> Order Items (bulk)
        List<OrderItem> orderItemsToInsert = new List<OrderItem>();
        for (QuoteLineItem qli : [
            SELECT Id, QuoteId, Product2Id, Quantity, UnitPrice, Discount, PricebookEntryId, Description
            FROM QuoteLineItem
            WHERE QuoteId IN :quoteToOrderMap.keySet()
        ]) {
            Id relatedOrderId = quoteToOrderMap.get(qli.QuoteId);
            if (relatedOrderId == null) continue;
            orderItemsToInsert.add(new OrderItem(
                OrderId = relatedOrderId,
                Product2Id = qli.Product2Id,
                Quantity = qli.Quantity,
                UnitPrice = qli.UnitPrice,
                PricebookEntryId = qli.PricebookEntryId,
                Description = qli.Description
            ));
        }
        if (!orderItemsToInsert.isEmpty()) insert orderItemsToInsert;

        // 6) Send one email per Opportunity Owner (bulk-safe)
        Set<Id> oppIds = new Set<Id>();
        for (Quote q : acceptedQuotes) if (q.OpportunityId != null) oppIds.add(q.OpportunityId);

        Map<Id, Opportunity> oppById = new Map<Id, Opportunity>();
        if (!oppIds.isEmpty()) {
            oppById = new Map<Id, Opportunity>([
                SELECT Id, Owner.Id, Owner.Name, Owner.Email
                FROM Opportunity
                WHERE Id IN :oppIds
            ]);
        }

        Map<Id, List<Quote>> oppToQuotes = new Map<Id, List<Quote>>();
        for (Quote q : acceptedQuotes) {
            if (q.OpportunityId == null) continue;
            oppToQuotes.computeIfAbsent(q.OpportunityId, (Id) -> new List<Quote>());
            oppToQuotes.get(q.OpportunityId).add(q);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String baseUrl = URL.getOrgDomainUrl().toExternalForm();
        for (Id oppId : oppToQuotes.keySet()) {
            Opportunity opp = oppById.get(oppId);
            if (opp == null || String.isBlank(opp.Owner.Email)) continue;

            List<Quote> qList = oppToQuotes.get(oppId);
            String body = 'Hello ' + opp.Owner.Name + ',\n\n';
            body += 'The following Quote(s) have been accepted and Orders created:\n';
            for (Quote q : qList) {
                body += '- ' + q.Name + ' (' + baseUrl + '/' + q.Id + ')\n';
            }
            body += '\nThanks.';

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { opp.Owner.Email });
            mail.setSubject('Quote(s) Accepted for Opportunity ' + oppId);
            mail.setPlainTextBody(body);
            emails.add(mail);
        }
        if (!emails.isEmpty()) Messaging.sendEmail(emails);

        // 7) Publish ARES notifications (guarded if package not installed)
        Boolean hasAres = Schema.getGlobalDescribe().containsKey('ares_notify__Notification__e');
        if (hasAres) {
            List<sObject> events = new List<sObject>();
            for (Quote q : acceptedQuotes) {
                sObject e = Schema.getGlobalDescribe().get('ares_notify__Notification__e').newSObject();
                e.put('ares_notify__Title__c', 'Quote Accepted');
                e.put('ares_notify__Body__c', 'Quote "' + q.Name + '" has been accepted and an Order has been created.');
                e.put('ares_notify__ContextId__c', q.OpportunityId != null ? q.OpportunityId : q.Id);
                e.put('ares_notify__RecipientId__c', q.OwnerId);
                e.put('ares_notify__TargetId__c', q.Id);
                e.put('ares_notify__IconName__c', 'standard:quote');
                e.put('ares_notify__TimeToLive__c', 120);
                e.put('ares_notify__ConvertToStandardNotification__c', true);
                events.add(e);
            }
            if (!events.isEmpty()) EventBus.publish(events);
        }
    }
}