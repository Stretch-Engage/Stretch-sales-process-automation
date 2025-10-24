/**
 * @author Sidharrth Nandhakumar
 * @date 2025-10-17
 * @description Creates a Quote (and copies OLI -> QLI) when Opportunity moves to Proposal/Quote.
 */
public class OpportunityTriggerHandler {

    public static void createQuoteAndQuoteLines(List<Opportunity> newOpps, Map<Id, Opportunity> oldMap) {
        if (newOpps == null || newOpps.isEmpty()) return;

        Set<Id> oppIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        // Identify Opps that just moved to Proposal/Quote
        for (Opportunity opp : newOpps) {
            Opportunity oldOpp = oldMap != null ? oldMap.get(opp.Id) : null;
            if (opp.StageName == 'Proposal/Quote' && (oldOpp == null || oldOpp.StageName != 'Proposal/Quote')) {
                oppIds.add(opp.Id);
                if (opp.ContactId != null) contactIds.add(opp.ContactId);
            }
        }
        if (oppIds.isEmpty()) return;

        // Query Opps with Account details
        Map<Id, Opportunity> oppWithAccounts = new Map<Id, Opportunity>([
            SELECT Id, Name, CloseDate, OwnerId, Pricebook2Id,
                   AccountId,
                   Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                   Account.ShippingStreet, Account.ShippingCity, Account.ShippingState, Account.ShippingPostalCode, Account.ShippingCountry,
                   ContactId
            FROM Opportunity
            WHERE Id IN :oppIds
        ]);

        // Related Contacts
        Map<Id, Contact> contactsById = new Map<Id, Contact>();
        if (!contactIds.isEmpty()) {
            contactsById = new Map<Id, Contact>([
                SELECT Id, FirstName, LastName, Email, Phone
                FROM Contact
                WHERE Id IN :contactIds
            ]);
        }

        // Create Quotes
        List<Quote> quotesToInsert = new List<Quote>();
        for (Opportunity opp : oppWithAccounts.values()) {
            Account acc = opp.Account;
            Contact con = opp.ContactId != null ? contactsById.get(opp.ContactId) : null;

            Quote q = new Quote(
                Name = opp.Name + ' Quote',
                OpportunityId = opp.Id,
                Pricebook2Id = opp.Pricebook2Id,
                ExpirationDate = opp.CloseDate,
                OwnerId = opp.OwnerId,
                ContactId = opp.ContactId
            );

            if (acc != null) {
                q.BillingStreet = acc.BillingStreet;
                q.BillingCity = acc.BillingCity;
                q.BillingState = acc.BillingState;
                q.BillingPostalCode = acc.BillingPostalCode;
                q.BillingCountry = acc.BillingCountry;
                q.ShippingStreet = acc.ShippingStreet;
                q.ShippingCity = acc.ShippingCity;
                q.ShippingState = acc.ShippingState;
                q.ShippingPostalCode = acc.ShippingPostalCode;
                q.ShippingCountry = acc.ShippingCountry;
            }

            if (con != null) {
                q.Email = con.Email;
                q.Phone = con.Phone;
            }

            quotesToInsert.add(q);
        }
        if (!quotesToInsert.isEmpty()) insert quotesToInsert;

        // Map OLI -> QLI
        Map<Id, List<OpportunityLineItem>> oppToLineItems = new Map<Id, List<OpportunityLineItem>>();
        for (OpportunityLineItem oli : [
            SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice, Discount, PricebookEntryId
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
        ]) {
            oppToLineItems.computeIfAbsent(oli.OpportunityId, (Id) -> new List<OpportunityLineItem>());
            oppToLineItems.get(oli.OpportunityId).add(oli);
        }

        List<QuoteLineItem> qlisToInsert = new List<QuoteLineItem>();
        for (Quote q : quotesToInsert) {
            List<OpportunityLineItem> relatedItems = oppToLineItems.get(q.OpportunityId);
            if (relatedItems == null) continue;
            for (OpportunityLineItem oli : relatedItems) {
                qlisToInsert.add(new QuoteLineItem(
                    QuoteId = q.Id,
                    Product2Id = oli.Product2Id,
                    Quantity = oli.Quantity,
                    UnitPrice = oli.UnitPrice,
                    Discount = oli.Discount,
                    PricebookEntryId = oli.PricebookEntryId
                ));
            }
        }
        if (!qlisToInsert.isEmpty()) insert qlisToInsert;
    }
}