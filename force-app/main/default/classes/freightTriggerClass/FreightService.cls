public with sharing class FreightService {

    public static void validateFreightDuplicity(List<Freight__c> freights){
        Set<String> newKeys = new Set<String>();
        Set<Id> existingIds = new Set<Id>();
        Set<Id> newProductIds    = new Set<Id>();
        Set<Id> newHierarchyIds  = new Set<Id>();
        Set<Id> newDcIds         = new Set<Id>();

        for (Freight__c f : freights) {
            String key = generateKey(f);

            if (newKeys.contains(key)) {
                f.addError('Error: Duplicate record in same batch for combination: ' + key);
            }
            newKeys.add(key);

            if (f.Id != null)                    existingIds.add(f.Id);
            if (f.Product__c != null)            newProductIds.add(f.Product__c);
            if (f.ProductHierarchy__c != null)   newHierarchyIds.add(f.ProductHierarchy__c);
            if (f.DistributionCenter__c != null) newDcIds.add(f.DistributionCenter__c);
        }

        Map<String, Freight__c> existingMap = new Map<String, Freight__c>();

        for(Freight__c existing : [SELECT Id, Product__c, ProductHierarchy__c, State__c, City__c, Country__c, DistributionCenter__c
                                    FROM Freight__c
                                    WHERE Status__c = 'Approved'
                                    AND Id NOT IN :existingIds
                                    AND DistributionCenter__c IN :newDcIds
                                    AND (Product__c IN :newProductIds OR ProductHierarchy__c IN :newHierarchyIds)]) {
            existingMap.put(generateKey(existing), existing);
        }

        for(Freight__c newRecord : freights) {
            String newKey = generateKey(newRecord);
            if (existingMap.containsKey(newKey)) {
                newRecord.addError('An active Freight record already exists for this exact combination: ' + newKey + ' (product/hierarchy/dc/state/city/country)');
            }
        }
    }

    private static String generateKey(Freight__c f) {
        return  (f.Product__c != null ? (String)f.Product__c : 'null') + '|' +
                (f.ProductHierarchy__c != null ? (String)f.ProductHierarchy__c : 'null') + '|' +
                (f.DistributionCenter__c != null ? (String)f.DistributionCenter__c : 'null') + '|' +
                (f.City__c != null ? (String)f.City__c : 'null') + '|' +
                (f.State__c != null ? (String)f.State__c : 'null') + '|' +
                (f.Country__c != null ? (String)f.Country__c : 'null');
    }


}
