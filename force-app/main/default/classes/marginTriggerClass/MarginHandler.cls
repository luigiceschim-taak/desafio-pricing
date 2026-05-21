public with sharing class MarginHandler extends MarginTriggerHandler {

    public override void beforeInsert() {
        MarginService.validateMarginDuplicity((List<Margin__c>)Trigger.new);
    }
    public override void beforeUpdate() {
        MarginService.validateMarginDuplicity((List<Margin__c>)Trigger.new);
    }


}
