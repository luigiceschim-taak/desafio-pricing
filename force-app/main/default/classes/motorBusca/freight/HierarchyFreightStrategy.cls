public class HierarchyFreightStrategy extends FreightStrategy {
    public override Freight__c search(FreightContext ctx, Map<String, Freight__c> rulesMap) {
        return searchByGeography(ctx.hId, ctx, rulesMap);
    }
}
