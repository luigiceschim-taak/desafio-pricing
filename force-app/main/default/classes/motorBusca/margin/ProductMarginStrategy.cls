public class ProductMarginStrategy extends MarginStrategy {
    public override Margin__c search(MarginContext ctx, Map<String, Margin__c> rulesMap) {
        Margin__c m = null;

        m = findMarginComplete(ctx.pId, ctx.cntId, ctx, rulesMap);
        if (m != null) return m;

        m = findMarginComplete(ctx.pId, ctx.hCntId, ctx, rulesMap);
        if (m != null) return m;

        return null;
    }
}
