public class MargemHierarquiaStrategy extends MargemStrategy {
    public override Margem__c search(ContextoMargem ctx, Map<String, Margem__c> mapaRegras) {
        Margem__c m = null;

        // 1. Tenta: HIERARQUIA + CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.hId, ctx.cntId, ctx, mapaRegras);
        if (m != null) return m;

        // 2. Tenta: HIERARQUIA + GRUPO CONTA + CD + GEO
        m = buscarMargemCompleta(ctx.hId, ctx.hCntId, ctx, mapaRegras);
        if (m != null) return m;

        return null;
    }
}