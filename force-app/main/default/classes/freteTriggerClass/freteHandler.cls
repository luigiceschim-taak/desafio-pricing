public with sharing class freteHandler extends freteTriggerHandler {
    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');
        FreteService.validarDuplicidadeFrete((List<Frete__c>) Trigger.new);
    }

    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        FreteService.validarDuplicidadeFrete((List<Frete__c>) Trigger.new);

    }

    
}