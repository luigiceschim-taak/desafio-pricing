public class TaxHandler extends TaxTriggerHandler {

    public override void beforeInsert() {
        TaxService.validateTaxDuplicity((List<Tax__c>)Trigger.new);
    }

    public override void beforeUpdate() {
        TaxService.validateTaxDuplicity((List<Tax__c>)Trigger.new);
    }



}
