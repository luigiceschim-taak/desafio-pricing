public with sharing class MarginService {

    public static void validateMarginDuplicity(List<Margin__c> margins){
        Set<String> newKeys = new Set<String>();
        Set<Id> existingIds      = new Set<Id>();
        Set<Id> newProductIds    = new Set<Id>();
        Set<Id> newHierarchyIds  = new Set<Id>();
        Set<Id> newAccountIds    = new Set<Id>();
        Set<Id> newGroupIds      = new Set<Id>();

        for (Margin__c m : margins) {
            String key = generateKey(m);

            if (newKeys.contains(key)) {
                m.addError('Error: Duplicate records in same batch for combination: ' + key);
            }
            newKeys.add(key);

            if (m.Id != null)                  existingIds.add(m.Id);
            if (m.Product__c != null)          newProductIds.add(m.Product__c);
            if (m.ProductHierarchy__c != null) newHierarchyIds.add(m.ProductHierarchy__c);
            if (m.Account__c != null)          newAccountIds.add(m.Account__c);
            if (m.AccountGroup__c != null)     newGroupIds.add(m.AccountGroup__c);
        }

        Map<String, Margin__c> existingMap = new Map<String, Margin__c>();

        for (Margin__c existing : [SELECT Id, Product__c, ProductHierarchy__c, Account__c,
                                    AccountGroup__c, City__c, State__c, Country__c, DistributionCenter__c
                                    FROM Margin__c
                                    WHERE Status__c = 'Approved'
                                    AND Id NOT IN :existingIds
                                    AND (Product__c IN :newProductIds OR ProductHierarchy__c IN :newHierarchyIds)
                                    AND (Account__c IN :newAccountIds OR AccountGroup__c IN :newGroupIds)]) {

            existingMap.put(generateKey(existing), existing);
        }


        for (Margin__c newRecord : margins) {
            String newKey = generateKey(newRecord);
            if (existingMap.containsKey(newKey)) {
                newRecord.addError('An active Margin record already exists for this exact combination of Product/Account/Location/Distribution Center.');
            }
        }
    }

    private static String generateKey(Margin__c m) {
        return  (m.Product__c != null ? (String)m.Product__c : (String)m.ProductHierarchy__c) + '|' +
                (m.Account__c != null ? (String)m.Account__c : (String)m.AccountGroup__c) + '|' +
                (m.DistributionCenter__c != null ? (String)m.DistributionCenter__c : 'NoDC') + '|' +
                (m.City__c != null ? (String)m.City__c :
                (m.State__c != null ? (String)m.State__c : (String)m.Country__c));
    }
}
