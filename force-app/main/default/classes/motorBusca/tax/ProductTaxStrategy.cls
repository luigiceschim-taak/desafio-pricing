public class ProductTaxStrategy extends TaxStrategy {
    public override Tax__c search(TaxContext ctx, Map<String, Tax__c> rulesMap) {
        return searchByGeography(ctx.pId, ctx, rulesMap);
    }
}
