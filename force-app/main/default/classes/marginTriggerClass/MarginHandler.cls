public with sharing class MarginHandler extends MarginTriggerHandler {

    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');
        MarginService.validarDuplicidadeMargem((List<Margin__c>)Trigger.new);
    }
    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        MarginService.validarDuplicidadeMargem((List<Margin__c>)Trigger.new);
    }


}