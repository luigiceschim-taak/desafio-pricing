public class TaxHandler extends TaxTriggerHandler {

    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');
        TaxService.validarDuplicidadeImposto((List<Tax__c>)Trigger.new);
    }



    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        TaxService.validarDuplicidadeImposto((List<Tax__c>)Trigger.new);
    }



}