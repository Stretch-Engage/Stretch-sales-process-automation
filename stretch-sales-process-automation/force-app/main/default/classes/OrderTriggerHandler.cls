/**
 * @author Sidharrth Nandhakumar
 * @date 2025-10-17
 * @description Updates Opportunity to Closed Won when related Order moves to Shipped.
 */
public class OrderTriggerHandler {

    public static void updateOpportunityWhenShipped(List<Order> newOrders, Map<Id, Order> oldMap) {
        if (newOrders == null || newOrders.isEmpty()) return;

        Set<Id> quoteIds = new Set<Id>();
        for (Order ord : newOrders) {
            Order oldOrd = oldMap != null ? oldMap.get(ord.Id) : null;
            if (ord.Status == 'Shipped' && oldOrd != null && oldOrd.Status != 'Shipped' && ord.QuoteId != null) {
                quoteIds.add(ord.QuoteId);
            }
        }
        if (quoteIds.isEmpty()) return;

        Map<Id, Id> quoteToOppMap = new Map<Id, Id>();
        for (Quote q : [SELECT Id, OpportunityId FROM Quote WHERE Id IN :quoteIds AND OpportunityId != null]) {
            quoteToOppMap.put(q.Id, q.OpportunityId);
        }
        if (quoteToOppMap.isEmpty()) return;

        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        for (Order ord : newOrders) {
            if (ord.QuoteId != null && quoteToOppMap.containsKey(ord.QuoteId)) {
                oppsToUpdate.add(new Opportunity(
                    Id = quoteToOppMap.get(ord.QuoteId),
                    StageName = 'Closed Won'
                ));
            }
        }
        if (!oppsToUpdate.isEmpty()) update oppsToUpdate;
    }
}