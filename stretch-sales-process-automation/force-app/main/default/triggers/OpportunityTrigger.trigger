trigger OpportunityTrigger on Opportunity (after insert, after update) {
    OpportunityTriggerHandler.createQuoteAndQuoteLines(Trigger.new, Trigger.oldMap);
}
