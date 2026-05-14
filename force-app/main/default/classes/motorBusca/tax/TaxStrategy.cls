public abstract class TaxStrategy {
    // Método que cada estratégia deve implementar (Produto)
    public abstract Tax__c search(TaxContext ctx, Map<String, Tax__c> mapaRegras);

    // Método utilitário comum: tenta buscar na escada geográfica
    protected Tax__c buscarNaGeografia(Id alvoId, TaxContext ctx, Map<String, Tax__c> mapaRegras) {
        if (alvoId == null) return null;
        String aId = String.valueOf(alvoId);

        if(ctx.cdId != null && ctx.estId != null) {
            String chaveTripla = String.valueOf(aId) + String.valueOf(ctx.cdId) + String.valueOf(ctx.estId);
            System.debug('>>> [TaxStrategy] Tentando chave TRIPLA: ' + chaveTripla);
            if (mapaRegras.containsKey(chaveTripla)) return mapaRegras.get(chaveTripla);
        }

        System.debug('>>> [TaxStrategy] Nenhuma chave geográfica encontrada para o alvo ' + alvoId);
        return null;
    }
}