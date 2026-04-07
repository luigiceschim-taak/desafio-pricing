public abstract class ImpostoStrategy {
    // Método que cada estratégia deve implementar (Produto)
    public abstract Imposto__c search(ContextoImposto ctx, Map<String, Imposto__c> mapaRegras);

    // Método utilitário comum: tenta buscar na escada geográfica
    protected Imposto__c buscarNaGeografia(Id alvoId, ContextoImposto ctx, Map<String, Imposto__c> mapaRegras) {
        if (alvoId == null) return null;
        String aId = String.valueOf(alvoId);

        if(ctx.cdId != null && ctx.estId != null) {
            String chaveTripla = String.valueOf(aId) + String.valueOf(ctx.cdId) + String.valueOf(ctx.estId);
            System.debug('>>> [ImpostoStrategy] Tentando chave TRIPLA: ' + chaveTripla);
            if (mapaRegras.containsKey(chaveTripla)) return mapaRegras.get(chaveTripla);
        }

        System.debug('>>> [ImpostoStrategy] Nenhuma chave geográfica encontrada para o alvo ' + alvoId);
        return null; 
    }
}