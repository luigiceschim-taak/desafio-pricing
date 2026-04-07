public with sharing class MargemHandler extends MargemTriggerHandler {
    
    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');
        MargemService.validarDuplicidadeMargem((List<Margem__c>)Trigger.new);
    }
    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        MargemService.validarDuplicidadeMargem((List<Margem__c>)Trigger.new);
    }

    
}