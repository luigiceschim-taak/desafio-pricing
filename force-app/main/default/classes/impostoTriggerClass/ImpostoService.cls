public with sharing class ImpostoService {

    public static void validarDuplicidadeImposto(List<Imposto__c> impostos){
        Set<String> chavesNovas = new Set<String>();
        Set<Id> idsExistentesNoLote = new Set<Id>();
    
        // 1. Coleta chaves do lote e valida valores básicos
        for (Imposto__c i : impostos) {
            if (i.Imposto_Custo__c == null || i.Imposto_Custo__c <= 0) {
                i.addError('O valor do Imposto de Custo deve ser maior que zero.');
            }
            
            String chave = gerarChave(i);
            
            // Valida duplicidade dentro do próprio lote (ex: duas linhas iguais no Excel)
            if (chavesNovas.contains(chave)) {
                i.addError('Erro: Registro duplicado no mesmo lote para a combinação: ' + chave);
            }
            chavesNovas.add(chave);
            
            if (i.Id != null) idsExistentesNoLote.add(i.Id);
        }

        // 2. Busca no banco APENAS os registros que coincidem com as chaves do lote
        // Usamos um Map para que a verificação seja instantânea depois
        Map<String, Imposto__c> mapaExistentes = new Map<String, Imposto__c>();
        
        
        for (Imposto__c existente : [SELECT Id, Product__c, Centro_Distribuicao__c, Estado__c 
                                    FROM Imposto__c 
                                    WHERE Id NOT IN :idsExistentesNoLote]) {
            
            // Adicionamos ao mapa: Chave -> Registro
            mapaExistentes.put(gerarChave(existente), existente);
        }

        // 3. Comparação Final 
        for (Imposto__c novo : impostos) {
            String chaveNovo = gerarChave(novo);
            
            if (mapaExistentes.containsKey(chaveNovo)) {

                novo.addError('Já existe um registro de Imposto Ativo com esta exata combinação: ' + chaveNovo);
            }
        }
    }

    private static String gerarChave(Imposto__c i) {
        return  (i.Product__c != null ? (String)i.Product__c : 'null') + '|' +
                (i.Centro_Distribuicao__c != null ? (String)i.Centro_Distribuicao__c : 'null') + '|' +
                (i.Estado__c != null ? (String)i.Estado__c : 'null');
    }


}