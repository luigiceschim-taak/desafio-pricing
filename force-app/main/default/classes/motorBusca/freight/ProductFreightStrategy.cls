public class ProductFreightStrategy extends FreightStrategy {
    public override Freight__c search(FreightContext ctx, Map<String, Freight__c> rulesMap) {
        return searchByGeography(ctx.pId, ctx, rulesMap);
    }
}
