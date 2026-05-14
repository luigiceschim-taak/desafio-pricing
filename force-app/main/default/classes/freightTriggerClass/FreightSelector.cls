public class FreightSelector {
    public FreightSelector (){

    }
    public static Map<String, Freight__c> getMapaRegras(Set<Id> produtosIds, Set<Id> hierarquiasIds, Set<Id> locaisIds, Set<Id> cdsIds) {
        Map<String, Freight__c> mapaRegras = new Map<String, Freight__c>();

        // A Query Única
        // O CD aqui serve apenas para restringir o universo de busca
        List<Freight__c> fretes = [
            SELECT Cost__c, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, DistributionCenter__c
            FROM Freight__c
            WHERE Status__c = 'Approved'
            AND DistributionCenter__c IN :cdsIds // O CD manda aqui!
            AND (
                Product__c IN :produtosIds OR
                ProductHierarchy__c IN :hierarquiasIds
            )


        ];
        System.debug(fretes + ' | ' + 'fretes encontrados para os cds');


        // Montagem da Chave Composta
        for (Freight__c f : fretes) {
            Id alvoId = (f.Product__c != null) ? f.Product__c : f.ProductHierarchy__c;

            // Identifica qual o nível geográfico real deste registro
            Id geoId = (f.City__c != null) ? f.City__c :
                    (f.State__c != null) ? f.State__c :
                    (f.Country__c != null) ? f.Country__c : f.DistributionCenter__c;

            if (alvoId != null && geoId != null) {
                // Use String.valueOf para garantir consistência de IDs
                mapaRegras.put(String.valueOf(alvoId) + String.valueOf(geoId), f);
            }
        }
        return mapaRegras;
    }
}