public class ImpostoSelector {
    public static Map<String, Imposto__c> getMapaRegras(Set<Id> produtosIds, Set<Id> locaisIds, Set<Id> cdsIds) {
        Map<String, Imposto__c> mapaRegras = new Map<String, Imposto__c>();

        // A Query Única
        // O CD aqui serve apenas para restringir o universo de busca
        List<Imposto__c> impostos = [
            SELECT Id, Imposto_Custo__c, Product__c, Estado__c, Centro_Distribuicao__c
            FROM Imposto__c
            WHERE Status__c = 'Aprovado'
            AND Centro_Distribuicao__c IN :cdsIds 
            AND Product__c IN :produtosIds  
            
            
        ];
        System.debug(impostos + ' | ' + 'impostos encontrados para os cds');


        // Montagem da Chave Composta
        for (Imposto__c i : impostos) {
            String chaveMestra = String.valueOf(i.Product__c) + 
                         String.valueOf(i.Centro_Distribuicao__c) + 
                         String.valueOf(i.Estado__c);
    
        mapaRegras.put(chaveMestra, i);
            
        }
        return mapaRegras;
    }
}