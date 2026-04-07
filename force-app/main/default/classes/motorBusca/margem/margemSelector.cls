public class margemSelector {
    public static Map<String, Margem__c> getMapaRegras(Set<Id> produtosIds, Set<Id> locaisIds, Set<Id> cdsIds, Set<Id> contasIds, Set<Id> gruposContasIds) {
        Map<String, Margem__c> mapaRegras = new Map<String, Margem__c>();

        List<Margem__c> margens = [
            SELECT Id, Valor__c, Conta__c, Grupo_Conta__c,
                   Produto__c, Hierarquia_Produto__c,
                   Cidade__c, Estado__c, Pais__c, Centro_Distribuicao__c
            FROM Margem__c
            WHERE Status__c = 'Aprovado'
            AND (Produto__c IN :produtosIds OR Hierarquia_Produto__c IN :produtosIds) 
            AND (Conta__c IN :contasIds OR Grupo_Conta__c IN :gruposContasIds)
        ];

        for (Margem__c m : margens) {
            Id pAlvo = (m.Produto__c != null) ? m.Produto__c : m.Hierarquia_Produto__c;
            Id cAlvo = (m.Conta__c != null) ? m.Conta__c : m.Grupo_Conta__c;
            
            // Lógica de Geografia (prioridade)
            Id gAlvo = (m.Cidade__c != null) ? m.Cidade__c : 
                       (m.Estado__c != null) ? m.Estado__c : m.Pais__c;

            if (pAlvo != null && cAlvo != null) {
                // Montagem Segura da Chave: Concatenamos apenas campos não nulos
                String chaveMestra = String.valueOf(pAlvo) + String.valueOf(cAlvo);
                
                if(m.Centro_Distribuicao__c != null) chaveMestra += String.valueOf(m.Centro_Distribuicao__c);
                if(gAlvo != null) chaveMestra += String.valueOf(gAlvo);
    
                mapaRegras.put(chaveMestra, m);
            }
        }
        return mapaRegras;
    }
}