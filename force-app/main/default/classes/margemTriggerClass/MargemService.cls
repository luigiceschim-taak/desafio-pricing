public with sharing class MargemService {

    public static void validarDuplicidadeMargem(List<Margem__c> margens){
        Set<String> chavesNovas = new Set<String>();
        Set<Id> chavesExistentes = new Set<id>();
        
        for (Margem__c m : margens) {
            String chave = gerarChave(m);
            System.debug('Chave gerada para validação: ' + chave);
            
            if (chavesNovas.contains(chave)) {
                m.addError('Erro: Você está tentando inserir registros duplicados no mesmo lote para a combinação: ' + chave);
            }
            chavesNovas.add(chave);

            if (m.Id != null) {
                chavesExistentes.add(m.Id);
            }
        }

        Map<String, Margem__c> mapaExistentes = new Map<String, Margem__c>();
        
       
        for (Margem__c existente : [SELECT Id, Produto__c, Hierarquia_Produto__c, Conta__c, Centro_Distribuicao__c,
                                    Grupo_Conta__c, Cidade__c, Estado__c, Pais__c 
                                    FROM Margem__c 
                                    WHERE Id NOT IN :chavesExistentes]) {
            
            
            mapaExistentes.put(gerarChave(existente), existente);
        }


        for (Margem__c nova : margens) {
        String chaveNova = gerarChave(nova);
        if (mapaExistentes.containsKey(chaveNova)) {
            nova.addError('Já existe um registro de Margem Ativo com esta exata combinação de Produto/Cliente/Localidade/Centro de Distribuição.');
        }
        }
    }

    private static String gerarChave(Margem__c m) {
        return  (m.Produto__c != null ? (String)m.Produto__c : (String)m.Hierarquia_Produto__c) + '|' +
                (m.Conta__c != null ? (String)m.Conta__c : (String)m.Grupo_Conta__c) + '|' +
                (m.Centro_Distribuicao__c != null ? (String)m.Centro_Distribuicao__c : 'SemCD') + '|' + 
                (m.Cidade__c != null ? (String)m.Cidade__c : 
                (m.Estado__c != null ? (String)m.Estado__c : (String)m.Pais__c));
    }
}