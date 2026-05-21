public abstract class MarginStrategy {
    public abstract Margin__c search(MarginContext ctx, Map<String, Margin__c> rulesMap);

    protected Margin__c findMarginComplete(Id productTarget, Id accountTarget, MarginContext ctx, Map<String, Margin__c> rulesMap) {
        if (productTarget == null || accountTarget == null || ctx.cdId == null) return null;

        String baseKey = String.valueOf(productTarget) + String.valueOf(accountTarget) + String.valueOf(ctx.cdId);

        if (ctx.cidId != null) {
            String cityKey = baseKey + String.valueOf(ctx.cidId);
            if (rulesMap.containsKey(cityKey)) return rulesMap.get(cityKey);
        }

        if (ctx.estId != null) {
            String stateKey = baseKey + String.valueOf(ctx.estId);
            if (rulesMap.containsKey(stateKey)) return rulesMap.get(stateKey);
        }

        if (ctx.paiId != null) {
            String countryKey = baseKey + String.valueOf(ctx.paiId);
            if (rulesMap.containsKey(countryKey)) return rulesMap.get(countryKey);
        }

        return null;
    }
}
