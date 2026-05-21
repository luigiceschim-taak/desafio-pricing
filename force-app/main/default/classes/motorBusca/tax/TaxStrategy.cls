public abstract class TaxStrategy {
    public abstract Tax__c search(TaxContext ctx, Map<String, Tax__c> rulesMap);

    protected Tax__c searchByGeography(Id targetId, TaxContext ctx, Map<String, Tax__c> rulesMap) {
        if (targetId == null) return null;
        String targetIdStr = String.valueOf(targetId);

        if(ctx.cdId != null && ctx.estId != null) {
            String tripleKey = targetIdStr + String.valueOf(ctx.cdId) + String.valueOf(ctx.estId);
            if (rulesMap.containsKey(tripleKey)) return rulesMap.get(tripleKey);
        }

        return null;
    }
}
