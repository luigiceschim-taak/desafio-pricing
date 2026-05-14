public abstract class FreightStrategy {
    // Método que cada estratégia deve implementar (Produto ou Hierarquia)
    public abstract Freight__c search(FreightContext ctx, Map<String, Freight__c> mapaRegras);

    // Método utilitário comum: tenta buscar na escada geográfica
    protected Freight__c buscarNaGeografia(Id alvoId, FreightContext ctx, Map<String, Freight__c> mapaRegras) {
        if (alvoId == null) return null;
        String aId = String.valueOf(alvoId);



        // 1. Tenta por CIDADE
        if (ctx.cidId != null) {
            String chaveCid = String.valueOf((Id)alvoId) + String.valueOf((Id)ctx.cidId);
            System.debug('>>> [FreightStrategy] Tentando chave CIDADE: ' + chaveCid);
            if (mapaRegras.containsKey(chaveCid)) return mapaRegras.get(chaveCid);
        }

        // 2. Tenta por ESTADO
        if (ctx.estId != null) {
            String chaveEst = String.valueOf((Id)alvoId) + String.valueOf((Id)ctx.estId);
            System.debug('>>> [FreightStrategy] Tentando chave ESTADO: ' + chaveEst);
            if (mapaRegras.containsKey(chaveEst)) return mapaRegras.get(chaveEst);
        }

        // 3. Tenta por PAÍS
        if (ctx.paiId != null) {
            String chavePai = String.valueOf((Id)alvoId) + String.valueOf((Id)ctx.paiId);
            System.debug('>>> [FreightStrategy] Tentando chave PAÍS: ' + chavePai);
            if (mapaRegras.containsKey(chavePai)) return mapaRegras.get(chavePai);
        }

        System.debug('>>> [FreightStrategy] Nenhuma chave geográfica encontrada para o alvo ' + alvoId);
        return null;
    }
}