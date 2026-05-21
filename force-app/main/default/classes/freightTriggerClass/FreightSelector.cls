public class FreightSelector {
    public FreightSelector (){

    }
    public static Map<String, Freight__c> getRulesMap(Set<Id> productIds, Set<Id> hierarchyIds, Set<Id> locationIds, Set<Id> dcIds) {
        Map<String, Freight__c> rulesMap = new Map<String, Freight__c>();

        List<Freight__c> freights = [
            SELECT Cost__c, Product__c, ProductHierarchy__c, City__c, State__c, Country__c, DistributionCenter__c
            FROM Freight__c
            WHERE Status__c = 'Approved'
            AND DistributionCenter__c IN :dcIds
            AND (
                Product__c IN :productIds OR
                ProductHierarchy__c IN :hierarchyIds
            )
        ];

        for (Freight__c f : freights) {
            Id targetId = (f.Product__c != null) ? f.Product__c : f.ProductHierarchy__c;

            Id geoId = (f.City__c != null) ? f.City__c :
                    (f.State__c != null) ? f.State__c :
                    (f.Country__c != null) ? f.Country__c : f.DistributionCenter__c;

            if (targetId != null && geoId != null) {
                rulesMap.put(String.valueOf(targetId) + String.valueOf(geoId), f);
            }
        }
        return rulesMap;
    }
}
