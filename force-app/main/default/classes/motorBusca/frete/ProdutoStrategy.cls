public class ProdutoStrategy extends FreteStrategy {
    public override Frete__c search(ContextoFrete ctx, Map<String, Frete__c> mapaRegras) {
        // Usa o motor geográfico focado no Produto
        return buscarNaGeografia(ctx.pId, ctx, mapaRegras);
    }
}