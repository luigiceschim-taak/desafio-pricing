public class HierarquiaStrategy extends FreteStrategy {
    public override Frete__c search(ContextoFrete ctx, Map<String, Frete__c> mapaRegras) {
        // Usa o motor geográfico focado na Hierarquia
        return buscarNaGeografia(ctx.hId, ctx, mapaRegras);
    }
}