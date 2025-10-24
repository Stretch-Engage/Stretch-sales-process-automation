trigger QuoteLineItemTrigger on QuoteLineItem (after insert, after update, after delete) {
    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            QuoteLineItemHandler.syncToOpportunity(Trigger.new);
        } else if (Trigger.isDelete) {
            QuoteLineItemHandler.handleDelete(Trigger.old);
        }
    }
}