trigger OrderTrigger on Order (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        OrderTriggerHandler.updateOpportunityWhenShipped(Trigger.new, Trigger.oldMap);
    }
}