public with sharing class TaxService {

    public static void validateTaxDuplicity(List<Tax__c> taxes){
        Set<String> newKeys = new Set<String>();
        Set<Id> existingIds = new Set<Id>();

        Set<Id> newProductIds = new Set<Id>();
        Set<Id> newDcIds      = new Set<Id>();

        for (Tax__c t : taxes) {
            if (t.TaxCost__c == null || t.TaxCost__c <= 0) {
                t.addError('Tax cost value must be greater than zero.');
            }

            String key = generateKey(t);

            if (newKeys.contains(key)) {
                t.addError('Error: Duplicate record in same batch for combination: ' + key);
            }
            newKeys.add(key);

            if (t.Id != null)                    existingIds.add(t.Id);
            if (t.Product__c != null)            newProductIds.add(t.Product__c);
            if (t.DistributionCenter__c != null) newDcIds.add(t.DistributionCenter__c);
        }

        Map<String, Tax__c> existingMap = new Map<String, Tax__c>();

        for (Tax__c existing : [SELECT Id, Product__c, DistributionCenter__c, State__c
                                    FROM Tax__c
                                    WHERE Status__c = 'Approved'
                                    AND Id NOT IN :existingIds
                                    AND Product__c IN :newProductIds
                                    AND DistributionCenter__c IN :newDcIds]) {

            existingMap.put(generateKey(existing), existing);
        }

        for (Tax__c newRecord : taxes) {
            String newKey = generateKey(newRecord);

            if (existingMap.containsKey(newKey)) {
                newRecord.addError('An active Tax record already exists for this exact combination: ' + newKey);
            }
        }
    }

    private static String generateKey(Tax__c t) {
        return  (t.Product__c != null ? (String)t.Product__c : 'null') + '|' +
                (t.DistributionCenter__c != null ? (String)t.DistributionCenter__c : 'null') + '|' +
                (t.State__c != null ? (String)t.State__c : 'null');
    }


}
