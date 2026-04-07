public class ProdutoImpostoStrategy extends ImpostoStrategy {
    public override Imposto__c search(ContextoImposto ctx, Map<String, Imposto__c> mapaRegras) {
        // Usa o motor geográfico focado no Produto
        return buscarNaGeografia(ctx.pId, ctx, mapaRegras);
    }
}