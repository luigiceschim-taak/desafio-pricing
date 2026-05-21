public class HierarchyMarginStrategy extends MarginStrategy {
    public override Margin__c search(MarginContext ctx, Map<String, Margin__c> rulesMap) {
        Margin__c m = null;

        m = findMarginComplete(ctx.hId, ctx.cntId, ctx, rulesMap);
        if (m != null) return m;

        m = findMarginComplete(ctx.hId, ctx.hCntId, ctx, rulesMap);
        if (m != null) return m;

        return null;
    }
}
