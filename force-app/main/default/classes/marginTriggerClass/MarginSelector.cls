public class MarginSelector {
    public static Map<String, Margin__c> getMapaRegras(Set<Id> produtosIds, Set<Id> hierarquiasIds, Set<Id> locaisIds, Set<Id> cdsIds, Set<Id> contasIds, Set<Id> gruposContasIds) {
        Map<String, Margin__c> mapaRegras = new Map<String, Margin__c>();

        List<Margin__c> margens = [
            SELECT Id, Cost__c, Account__c, AccountGroup__c,
                   Product__c, ProductHierarchy__c,
                   City__c, State__c, Country__c, DistributionCenter__c
            FROM Margin__c
            WHERE Status__c = 'Approved'
            AND (Product__c IN :produtosIds OR ProductHierarchy__c IN :hierarquiasIds)
            AND (Account__c IN :contasIds OR AccountGroup__c IN :gruposContasIds)
        ];

        for (Margin__c m : margens) {
            Id pAlvo = (m.Product__c != null) ? m.Product__c : m.ProductHierarchy__c;
            Id cAlvo = (m.Account__c != null) ? m.Account__c : m.AccountGroup__c;

            Id gAlvo = (m.City__c != null) ? m.City__c :
                       (m.State__c != null) ? m.State__c : m.Country__c;

            if (pAlvo != null && cAlvo != null) {
                String chaveMestra = String.valueOf(pAlvo) + String.valueOf(cAlvo);
                if (m.DistributionCenter__c != null) chaveMestra += String.valueOf(m.DistributionCenter__c);
                if (gAlvo != null) chaveMestra += String.valueOf(gAlvo);
                mapaRegras.put(chaveMestra, m);
            }
        }
        return mapaRegras;
    }
}