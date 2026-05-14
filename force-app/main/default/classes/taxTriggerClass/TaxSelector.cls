public class TaxSelector {
    public static Map<String, Tax__c> getMapaRegras(Set<Id> produtosIds, Set<Id> locaisIds, Set<Id> cdsIds) {
        Map<String, Tax__c> mapaRegras = new Map<String, Tax__c>();

        // A Query Única
        // O CD aqui serve apenas para restringir o universo de busca
        List<Tax__c> impostos =[
            SELECT Id, TaxCost__c, Product__c, State__c, DistributionCenter__c
            FROM Tax__c
            WHERE Status__c = 'Approved'
            AND DistributionCenter__c IN :cdsIds
            AND Product__c IN :produtosIds];

            System.debug('------------------------------------------------');
            System.debug('Impostos encontrados (TAX SELECTOR): ' + impostos.size());
            System.debug('------------------------------------------------');


        // Montagem da Chave Composta
        for (Tax__c i : impostos) {
            String chaveMestra = String.valueOf(i.Product__c) +
                         String.valueOf(i.DistributionCenter__c) +
                         String.valueOf(i.State__c);
            mapaRegras.put(chaveMestra, i);
        }
        return mapaRegras;
    }
}