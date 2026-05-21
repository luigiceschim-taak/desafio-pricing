public with sharing class FreightHandler extends FreightTriggerHandler {
    public override void beforeInsert() {
        FreightService.validateFreightDuplicity((List<Freight__c>) Trigger.new);
    }

    public override void beforeUpdate() {
        FreightService.validateFreightDuplicity((List<Freight__c>) Trigger.new);
    }


}
