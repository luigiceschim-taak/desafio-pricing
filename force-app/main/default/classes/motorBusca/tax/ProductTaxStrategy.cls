public class ProductTaxStrategy extends TaxStrategy {
    public override Tax__c search(TaxContext ctx, Map<String, Tax__c> mapaRegras) {
        // Usa o motor geográfico focado no Produto
        return buscarNaGeografia(ctx.pId, ctx, mapaRegras);
    }
}