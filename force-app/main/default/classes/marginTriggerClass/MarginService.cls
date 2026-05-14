public with sharing class MarginService {

    public static void validarDuplicidadeMargem(List<Margin__c> margens){
        Set<String> chavesNovas = new Set<String>();
        Set<Id> chavesExistentes = new Set<Id>();
        Set<Id> produtosNovos    = new Set<Id>();
        Set<Id> hierarquiasNovas = new Set<Id>();
        Set<Id> contasNovas      = new Set<Id>();
        Set<Id> gruposNovos      = new Set<Id>();

        for (Margin__c m : margens) {
            String chave = gerarChave(m);
            System.debug('Chave gerada para validação: ' + chave);

            if (chavesNovas.contains(chave)) {
                m.addError('Erro: Você está tentando inserir registros duplicados no mesmo lote para a combinação: ' + chave);
            }
            chavesNovas.add(chave);

            if (m.Id != null)                  chavesExistentes.add(m.Id);
            if (m.Product__c != null)          produtosNovos.add(m.Product__c);
            if (m.ProductHierarchy__c != null) hierarquiasNovas.add(m.ProductHierarchy__c);
            if (m.Account__c != null)          contasNovas.add(m.Account__c);
            if (m.AccountGroup__c != null)     gruposNovos.add(m.AccountGroup__c);
        }

        Map<String, Margin__c> mapaExistentes = new Map<String, Margin__c>();

        for (Margin__c existente : [SELECT Id, Product__c, ProductHierarchy__c, Account__c,
                                    AccountGroup__c, City__c, State__c, Country__c, DistributionCenter__c
                                    FROM Margin__c
                                    WHERE Status__c = 'Approved'
                                    AND Id NOT IN :chavesExistentes
                                    AND (Product__c IN :produtosNovos OR ProductHierarchy__c IN :hierarquiasNovas)
                                    AND (Account__c IN :contasNovas OR AccountGroup__c IN :gruposNovos)]) {

            mapaExistentes.put(gerarChave(existente), existente);
        }


        for (Margin__c nova : margens) {
        String chaveNova = gerarChave(nova);
        if (mapaExistentes.containsKey(chaveNova)) {
            nova.addError('Já existe um registro de Margem Ativo com esta exata combinação de Produto/Cliente/Localidade/Centro de Distribuição.');
        }
        }
    }

    private static String gerarChave(Margin__c m) {
        return  (m.Product__c != null ? (String)m.Product__c : (String)m.ProductHierarchy__c) + '|' +
                (m.Account__c != null ? (String)m.Account__c : (String)m.AccountGroup__c) + '|' +
                (m.DistributionCenter__c != null ? (String)m.DistributionCenter__c : 'SemCD') + '|' +
                (m.City__c != null ? (String)m.City__c :
                (m.State__c != null ? (String)m.State__c : (String)m.Country__c));
    }
}