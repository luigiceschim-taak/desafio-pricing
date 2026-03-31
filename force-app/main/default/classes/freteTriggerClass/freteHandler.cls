public with sharing class freteHandler extends freteTriggerHandler {
    public freteHandler() {

    }

    public override void beforeInsert() {
        // Lógica específica para before insert
        System.debug('Executando lógica de before insert');

        validarDuplicidadeFrete((List<Frete__c>) Trigger.new);
    }

    public override void beforeUpdate() {
        // Lógica específica para before update
        System.debug('Executando lógica de before update');
        validarDuplicidadeFrete((List<Frete__c>) Trigger.new);

    }

    private void validarDuplicidadeFrete(List<Frete__c> fretes){
        // Implementar lógica de validação de duplicidade similar ao exemplo do ImpostoHandler

        Set<String> chavesNovas = new Set<String>();
        Set<Id> idsExistentesNoLote = new Set<Id>();
        
        for (Frete__c f : fretes) {
            String chave = gerarChave(f);
            
            if (chavesNovas.contains(chave)) {
                f.addError('Erro: Registro duplicado no mesmo lote para a combinação: ' + chave);
            }
            chavesNovas.add(chave);
            
            if (f.Id != null) idsExistentesNoLote.add(f.Id);
        }

        Map<String, Frete__c> mapaExistentes = new Map<String, Frete__c>();

        for(Frete__c existente : [SELECT Id, Produto__c, Hierarquia_Produto__c, Estado__c, Cidade__c, Pais__c 
                                    FROM Frete__c 
                                    WHERE Status__c = 'Aprovado' 
                                    AND Id NOT IN :idsExistentesNoLote]) {
            mapaExistentes.put(gerarChave(existente), existente);
        }

        for(Frete__c novo : fretes) {
            String chaveNovo = gerarChave(novo);
            if (mapaExistentes.containsKey(chaveNovo)) {
                novo.addError('Já existe um registro de Frete Ativo com esta exata combinação: ' + chaveNovo);
            }
        }
    }

    private String gerarChave(Frete__c f) {
        return  (f.Produto__c != null ? (String)f.Produto__c : 'null') + '|' +
                (f.Hierarquia_Produto__c != null ? (String)f.Hierarquia_Produto__c : 'null') + '|' +
                (f.Cidade__c != null ? (String)f.Cidade__c : 'null') + '|' +
                (f.Estado__c != null ? (String)f.Estado__c : 'null') + '|' +
                (f.Pais__c != null ? (String)f.Pais__c : 'null');
        }
}