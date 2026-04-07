public class FreteSelector {
    public static Map<String, Frete__c> getMapaRegras(Set<Id> produtosIds, Set<Id> hierarquiasIds, Set<Id> locaisIds, Set<Id> cdsIds) {
        Map<String, Frete__c> mapaRegras = new Map<String, Frete__c>();

        // A Query Única
        // O CD aqui serve apenas para restringir o universo de busca
        List<Frete__c> fretes = [
            SELECT Valor__c, Produto__c, Hierarquia_Produto__c, Cidade__c, Estado__c, Pais__c, Centro_Distribuicao__c
            FROM Frete__c
            WHERE Status__c = 'Aprovado'
            AND Centro_Distribuicao__c IN :cdsIds // O CD manda aqui!
            AND (
                Produto__c IN :produtosIds OR 
                Hierarquia_Produto__c IN :hierarquiasIds
            )
            
            
        ];
        System.debug(fretes + ' | ' + 'fretes encontrados para os cds');


        // Montagem da Chave Composta
        for (Frete__c f : fretes) {
            Id alvoId = (f.Produto__c != null) ? f.Produto__c : f.Hierarquia_Produto__c;
            
            // Identifica qual o nível geográfico real deste registro
            Id geoId = (f.Cidade__c != null) ? f.Cidade__c : 
                    (f.Estado__c != null) ? f.Estado__c : 
                    (f.Pais__c != null) ? f.Pais__c : f.Centro_Distribuicao__c;

            if (alvoId != null && geoId != null) {
                // Use String.valueOf para garantir consistência de IDs
                mapaRegras.put(String.valueOf(alvoId) + String.valueOf(geoId), f);
            }
        }
        return mapaRegras;
    }
}