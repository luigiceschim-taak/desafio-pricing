public class MarginSelector {
    public static Map<String, Margin__c> getRulesMap(Set<Id> productIds, Set<Id> hierarchyIds, Set<Id> locationIds, Set<Id> dcIds, Set<Id> accountIds, Set<Id> accountGroupIds) {
        Map<String, Margin__c> rulesMap = new Map<String, Margin__c>();

        List<Margin__c> margins = [
            SELECT Id, Cost__c, Account__c, AccountGroup__c,
                   Product__c, ProductHierarchy__c,
                   City__c, State__c, Country__c, DistributionCenter__c
            FROM Margin__c
            WHERE Status__c = 'Approved'
            AND (Product__c IN :productIds OR ProductHierarchy__c IN :hierarchyIds)
            AND (Account__c IN :accountIds OR AccountGroup__c IN :accountGroupIds)
        ];

        for (Margin__c m : margins) {
            Id productTarget = (m.Product__c != null) ? m.Product__c : m.ProductHierarchy__c;
            Id accountTarget = (m.Account__c != null) ? m.Account__c : m.AccountGroup__c;

            Id geoTarget = (m.City__c != null) ? m.City__c :
                       (m.State__c != null) ? m.State__c : m.Country__c;

            if (productTarget != null && accountTarget != null) {
                String masterKey = String.valueOf(productTarget) + String.valueOf(accountTarget);
                if (m.DistributionCenter__c != null) masterKey += String.valueOf(m.DistributionCenter__c);
                if (geoTarget != null) masterKey += String.valueOf(geoTarget);
                rulesMap.put(masterKey, m);
            }
        }
        return rulesMap;
    }
}
