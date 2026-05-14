public class ProductFreightStrategy extends FreightStrategy {
    public override Freight__c search(FreightContext ctx, Map<String, Freight__c> mapaRegras) {
        // Usa o motor geográfico focado no Produto
        return buscarNaGeografia(ctx.pId, ctx, mapaRegras);
    }
}