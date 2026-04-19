public with sharing class FreteService {
  

    public static void validarDuplicidadeFrete(List<Frete__c> fretes){
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

        for(Frete__c existente : [SELECT Id, Produto__c, Hierarquia_Produto__c, Estado__c, Cidade__c, Pais__c, Centro_Distribuicao__c 
                                    FROM Frete__c 
                                    WHERE Id NOT IN :idsExistentesNoLote ]) {
            mapaExistentes.put(gerarChave(existente), existente);
        }

        for(Frete__c novo : fretes) {
            String chaveNovo = gerarChave(novo);
            if (mapaExistentes.containsKey(chaveNovo)) {
                novo.addError('Já existe um registro de Frete Ativo com esta exata combinação: ' + chaveNovo +  'produto/hierarquia/cd/estado/cidade/país');
            }
        }
    }

    private static String gerarChave(Frete__c f) {
        return  (f.Produto__c != null ? (String)f.Produto__c : 'null') + '|' +
                (f.Hierarquia_Produto__c != null ? (String)f.Hierarquia_Produto__c : 'null') + '|' +
                (f.Centro_Distribuicao__c != null ? (String)f.Centro_Distribuicao__c : 'null') + '|' +
                (f.Cidade__c != null ? (String)f.Cidade__c : 'null') + '|' +
                (f.Estado__c != null ? (String)f.Estado__c : 'null') + '|' +
                (f.Pais__c != null ? (String)f.Pais__c : 'null');
    }


}