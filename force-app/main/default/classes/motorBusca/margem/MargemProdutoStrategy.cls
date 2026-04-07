public class MargemProdutoStrategy extends MargemStrategy {
    public override Margem__c search(ContextoMargem ctx, Map<String, Margem__c> mapaRegras) {
        Margem__c m = null;

        // 1. Tenta: PRODUTO + CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.pId, ctx.cntId, ctx, mapaRegras);
        if (m != null) return m;

        // 2. Tenta: PRODUTO + GRUPO CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.pId, ctx.hCntId, ctx, mapaRegras);
        if (m != null) return m;

        return null;
    }
}