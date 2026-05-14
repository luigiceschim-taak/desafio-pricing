public with sharing class FreightHandler extends FreightTriggerHandler {
    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');
        FreightService.validarDuplicidadeFrete((List<Freight__c>) Trigger.new);
    }

    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        FreightService.validarDuplicidadeFrete((List<Freight__c>) Trigger.new);
    }


}