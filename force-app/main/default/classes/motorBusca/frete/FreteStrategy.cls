public abstract class FreteStrategy {
    // Método que cada estratégia deve implementar (Produto ou Hierarquia)
    public abstract Frete__c search(ContextoFrete ctx, Map<String, Frete__c> mapaRegras);

    // Método utilitário comum: tenta buscar na escada geográfica
    protected Frete__c buscarNaGeografia(Id alvoId, ContextoFrete ctx, Map<String, Frete__c> mapaRegras) {
        if (alvoId == null) return null;
        String aId = String.valueOf(alvoId);

        // 1. Tenta por Centro de Distribuição (Se o contexto tiver)
        if (ctx.cdId != null && mapaRegras.containsKey(aId + ctx.cdId)) 
            return mapaRegras.get(aId + ctx.cdId);

        // 1. Tenta por CIDADE
        if (ctx.cidId != null) {
            String chaveCid = String.valueOf((Id)alvoId) + String.valueOf((Id)ctx.cidId);
            System.debug('>>> [FreteStrategy] Tentando chave CIDADE: ' + chaveCid);
            if (mapaRegras.containsKey(chaveCid)) return mapaRegras.get(chaveCid);
        }

        // 2. Tenta por ESTADO
        if (ctx.estId != null) {
            String chaveEst = String.valueOf((Id)alvoId) + String.valueOf((Id)ctx.estId);
            System.debug('>>> [FreteStrategy] Tentando chave ESTADO: ' + chaveEst);
            if (mapaRegras.containsKey(chaveEst)) return mapaRegras.get(chaveEst);
        }

        // 3. Tenta por PAÍS
        if (ctx.paiId != null) {
            String chavePai = String.valueOf((Id)alvoId) + String.valueOf((Id)ctx.paiId);
            System.debug('>>> [FreteStrategy] Tentando chave PAÍS: ' + chavePai);
            if (mapaRegras.containsKey(chavePai)) return mapaRegras.get(chavePai);
        }

        System.debug('>>> [FreteStrategy] Nenhuma chave geográfica encontrada para o alvo ' + alvoId);
        return null; 
    }
}