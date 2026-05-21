public class TaxSelector {
    public static Map<String, Tax__c> getRulesMap(Set<Id> productIds, Set<Id> locationIds, Set<Id> dcIds) {
        Map<String, Tax__c> rulesMap = new Map<String, Tax__c>();

        List<Tax__c> taxes =[
            SELECT Id, TaxCost__c, Product__c, State__c, DistributionCenter__c
            FROM Tax__c
            WHERE Status__c = 'Approved'
            AND DistributionCenter__c IN :dcIds
            AND Product__c IN :productIds];

        for (Tax__c t : taxes) {
            String masterKey = String.valueOf(t.Product__c) +
                         String.valueOf(t.DistributionCenter__c) +
                         String.valueOf(t.State__c);
            rulesMap.put(masterKey, t);
        }
        return rulesMap;
    }
}
