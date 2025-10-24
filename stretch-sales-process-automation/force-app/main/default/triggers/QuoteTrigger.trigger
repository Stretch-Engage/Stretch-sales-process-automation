trigger QuoteTrigger on Quote (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        QuoteTriggerHandler.handleAcceptedQuotes(Trigger.new, Trigger.oldMap);
    }
}