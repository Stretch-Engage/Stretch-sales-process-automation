/**
 * @author Sidharrth Nandhakumar
 * @date 2025-10-17
 * @description Keeps OpportunityLineItems in sync with QuoteLineItems (insert/update/delete).
 */
public class QuoteLineItemHandler {

    public static void syncToOpportunity(List<QuoteLineItem> newQLIs) {
        if (newQLIs == null || newQLIs.isEmpty()) return;

        Set<Id> quoteIds = new Set<Id>();
        for (QuoteLineItem qli : newQLIs) if (qli.QuoteId != null) quoteIds.add(qli.QuoteId);
        if (quoteIds.isEmpty()) return;

        Map<Id, Quote> quotes = new Map<Id, Quote>([
            SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds AND OpportunityId != null
        ]);
        if (quotes.isEmpty()) return;

        Set<Id> oppIds = new Set<Id>();
        for (Quote q : quotes.values()) oppIds.add(q.OpportunityId);

        Map<Id, List<OpportunityLineItem>> oppToOLIs = new Map<Id, List<OpportunityLineItem>>();
        for (OpportunityLineItem oli : [
            SELECT Id, OpportunityId, Product2Id, Quantity, UnitPrice, Discount
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
        ]) {
            oppToOLIs.computeIfAbsent(oli.OpportunityId, (Id) -> new List<OpportunityLineItem>());
            oppToOLIs.get(oli.OpportunityId).add(oli);
        }

        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();

        for (QuoteLineItem qli : newQLIs) {
            Quote relatedQuote = quotes.get(qli.QuoteId);
            if (relatedQuote == null) continue;

            Id oppId = relatedQuote.OpportunityId;
            List<OpportunityLineItem> existingOLIs = oppToOLIs.get(oppId);

            OpportunityLineItem matchingOLI = null;
            if (existingOLIs != null) {
                for (OpportunityLineItem o : existingOLIs) {
                    if (o.Product2Id == qli.Product2Id) {
                        matchingOLI = o;
                        break;
                    }
                }
            }

            if (matchingOLI == null) {
                oliToInsert.add(new OpportunityLineItem(
                    OpportunityId = oppId,
                    Product2Id = qli.Product2Id,
                    Quantity = qli.Quantity,
                    UnitPrice = qli.UnitPrice,
                    Discount = qli.Discount,
                    PricebookEntryId = qli.PricebookEntryId
                ));
            } else {
                matchingOLI.Quantity = qli.Quantity;
                matchingOLI.UnitPrice = qli.UnitPrice;
                matchingOLI.Discount = qli.Discount;
                oliToUpdate.add(matchingOLI);
            }
        }

        if (!oliToInsert.isEmpty()) insert oliToInsert;
        if (!oliToUpdate.isEmpty()) update oliToUpdate;
    }

    public static void handleDelete(List<QuoteLineItem> oldQLIs) {
        if (oldQLIs == null || oldQLIs.isEmpty()) return;

        Set<Id> quoteIds = new Set<Id>();
        for (QuoteLineItem qli : oldQLIs) if (qli.QuoteId != null) quoteIds.add(qli.QuoteId);
        if (quoteIds.isEmpty()) return;

        Map<Id, Quote> quotes = new Map<Id, Quote>([
            SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds AND OpportunityId != null
        ]);
        if (quotes.isEmpty()) return;

        Set<Id> oppIds = new Set<Id>();
        for (Quote q : quotes.values()) oppIds.add(q.OpportunityId);

        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem qli : oldQLIs) productIds.add(qli.Product2Id);

        List<OpportunityLineItem> toDelete = [
            SELECT Id
            FROM OpportunityLineItem
            WHERE OpportunityId IN :oppIds
            AND Product2Id IN :productIds
        ];
        if (!toDelete.isEmpty()) delete toDelete;
    }
}