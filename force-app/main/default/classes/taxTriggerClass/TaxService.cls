public with sharing class TaxService {

    public static void validarDuplicidadeImposto(List<Tax__c> impostos){
        Set<String> chavesNovas = new Set<String>();
        Set<Id> idsExistentesNoLote = new Set<Id>();

        Set<Id> produtosNovos = new Set<Id>();
        Set<Id> cdsNovos      = new Set<Id>();

        // 1. Coleta chaves do lote e valida valores básicos
        for (Tax__c i : impostos) {
            if (i.TaxCost__c == null || i.TaxCost__c <= 0) {
                i.addError('O valor do Imposto de Custo deve ser maior que zero.');
            }

            String chave = gerarChave(i);

            if (chavesNovas.contains(chave)) {
                i.addError('Erro: Registro duplicado no mesmo lote para a combinação: ' + chave);
            }
            chavesNovas.add(chave);

            if (i.Id != null)                    idsExistentesNoLote.add(i.Id);
            if (i.Product__c != null)            produtosNovos.add(i.Product__c);
            if (i.DistributionCenter__c != null) cdsNovos.add(i.DistributionCenter__c);
        }

        // 2. Busca apenas registros que poderiam colidir com o lote atual
        Map<String, Tax__c> mapaExistentes = new Map<String, Tax__c>();

        for (Tax__c existente : [SELECT Id, Product__c, DistributionCenter__c, State__c
                                    FROM Tax__c
                                    WHERE Status__c = 'Approved'
                                    AND Id NOT IN :idsExistentesNoLote
                                    AND Product__c IN :produtosNovos
                                    AND DistributionCenter__c IN :cdsNovos]) {

            mapaExistentes.put(gerarChave(existente), existente);
        }

        // 3. Comparação Final
        for (Tax__c novo : impostos) {
            String chaveNovo = gerarChave(novo);

            if (mapaExistentes.containsKey(chaveNovo)) {

                novo.addError('Já existe um registro de Imposto Ativo com esta exata combinação: ' + chaveNovo);
            }
        }
    }

    private static String gerarChave(Tax__c i) {
        return  (i.Product__c != null ? (String)i.Product__c : 'null') + '|' +
                (i.DistributionCenter__c != null ? (String)i.DistributionCenter__c : 'null') + '|' +
                (i.State__c != null ? (String)i.State__c : 'null');
    }


}