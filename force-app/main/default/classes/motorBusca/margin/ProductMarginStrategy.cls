public class ProductMarginStrategy extends MarginStrategy {
    public override Margin__c search(MarginContext ctx, Map<String, Margin__c> mapaRegras) {
        Margin__c m = null;

        // 1. Tenta: PRODUTO + CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.pId, ctx.cntId, ctx, mapaRegras);
        if (m != null) return m;

        // 2. Tenta: PRODUTO + GRUPO CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.pId, ctx.hCntId, ctx, mapaRegras);
        if (m != null) return m;

        return null;
    }
}