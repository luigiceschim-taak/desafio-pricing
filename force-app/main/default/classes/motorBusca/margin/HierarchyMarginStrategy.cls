public class HierarchyMarginStrategy extends MarginStrategy {
    public override Margin__c search(MarginContext ctx, Map<String, Margin__c> mapaRegras) {
        Margin__c m = null;

        // 1. Tenta: HIERARQUIA + CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.hId, ctx.cntId, ctx, mapaRegras);
        if (m != null) return m;

        // 2. Tenta: HIERARQUIA + GRUPO CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.hId, ctx.hCntId, ctx, mapaRegras);
        if (m != null) return m;

        return null;
    }
}