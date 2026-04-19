public class ImpostoHandler extends ImpostoTriggerHandler {

    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');
        ImpostoService.validarDuplicidadeImposto((List<Imposto__c>)Trigger.new);
    }

    

    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        ImpostoService.validarDuplicidadeImposto((List<Imposto__c>)Trigger.new);
    }

   
    
}