public abstract class FreightStrategy {
    public abstract Freight__c search(FreightContext ctx, Map<String, Freight__c> rulesMap);

    protected Freight__c searchByGeography(Id targetId, FreightContext ctx, Map<String, Freight__c> rulesMap) {
        if (targetId == null) return null;

        if (ctx.cidId != null) {
            String cityKey = String.valueOf((Id)targetId) + String.valueOf((Id)ctx.cidId);
            if (rulesMap.containsKey(cityKey)) return rulesMap.get(cityKey);
        }

        if (ctx.estId != null) {
            String stateKey = String.valueOf((Id)targetId) + String.valueOf((Id)ctx.estId);
            if (rulesMap.containsKey(stateKey)) return rulesMap.get(stateKey);
        }

        if (ctx.paiId != null) {
            String countryKey = String.valueOf((Id)targetId) + String.valueOf((Id)ctx.paiId);
            if (rulesMap.containsKey(countryKey)) return rulesMap.get(countryKey);
        }

        return null;
    }
}
