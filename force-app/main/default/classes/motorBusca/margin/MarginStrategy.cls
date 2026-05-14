public abstract class MarginStrategy {
    public abstract Margin__c search(MarginContext ctx, Map<String, Margin__c> mapaRegras);

    // Agora o método recebe o ID do Produto (ou Hierarquia) E o ID da Conta (ou Grupo)
    protected Margin__c buscarMargemCompleta(Id pAlvo, Id cAlvo, MarginContext ctx, Map<String, Margin__c> mapaRegras) {
        if (pAlvo == null || cAlvo == null || ctx.cdId == null) return null;

        String baseChave = String.valueOf(pAlvo) + String.valueOf(cAlvo) + String.valueOf(ctx.cdId);

        // --- TENTATIVA 1: CIDADE ---
        if (ctx.cidId != null) {
            String chaveCid = baseChave + String.valueOf(ctx.cidId);
            if (mapaRegras.containsKey(chaveCid)) return mapaRegras.get(chaveCid);
        }

        // --- TENTATIVA 2: ESTADO ---
        if (ctx.estId != null) {
            String chaveEst = baseChave + String.valueOf(ctx.estId);
            if (mapaRegras.containsKey(chaveEst)) return mapaRegras.get(chaveEst);
        }

        // --- TENTATIVA 3: PAÍS ---
        if (ctx.paiId != null) {
            String chavePai = baseChave + String.valueOf(ctx.paiId);
            if (mapaRegras.containsKey(chavePai)) return mapaRegras.get(chavePai);
        }

        return null;
    }
}