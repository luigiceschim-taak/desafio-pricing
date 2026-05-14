public with sharing class FreightService {


    public static void validarDuplicidadeFrete(List<Freight__c> fretes){
        // Implementar lógica de validação de duplicidade similar ao exemplo do ImpostoHandler

        Set<String> chavesNovas = new Set<String>();
        Set<Id> idsExistentesNoLote = new Set<Id>();

        for (Freight__c f : fretes) {
            String chave = gerarChave(f);

            if (chavesNovas.contains(chave)) {
                f.addError('Erro: Registro duplicado no mesmo lote para a combinação: ' + chave);
            }
            chavesNovas.add(chave);

            if (f.Id != null) idsExistentesNoLote.add(f.Id);
        }

        Map<String, Freight__c> mapaExistentes = new Map<String, Freight__c>();

        for(Freight__c existente : [SELECT Id, Product__c, ProductHierarchy__c, State__c, City__c, Country__c, DistributionCenter__c
                                    FROM Freight__c
                                    WHERE Id NOT IN :idsExistentesNoLote ]) {
            mapaExistentes.put(gerarChave(existente), existente);
        }

        for(Freight__c novo : fretes) {
            String chaveNovo = gerarChave(novo);
            if (mapaExistentes.containsKey(chaveNovo)) {
                novo.addError('Já existe um registro de Frete Ativo com esta exata combinação: ' + chaveNovo +  'produto/hierarquia/cd/estado/cidade/país');
            }
        }
    }

    private static String gerarChave(Freight__c f) {
        return  (f.Product__c != null ? (String)f.Product__c : 'null') + '|' +
                (f.ProductHierarchy__c != null ? (String)f.ProductHierarchy__c : 'null') + '|' +
                (f.DistributionCenter__c != null ? (String)f.DistributionCenter__c : 'null') + '|' +
                (f.City__c != null ? (String)f.City__c : 'null') + '|' +
                (f.State__c != null ? (String)f.State__c : 'null') + '|' +
                (f.Country__c != null ? (String)f.Country__c : 'null');
    }


}