public class HierarchyFreightStrategy extends FreightStrategy {
    public override Freight__c search(FreightContext ctx, Map<String, Freight__c> mapaRegras) {
        // Usa o motor geográfico focado na Hierarquia
        return buscarNaGeografia(ctx.hId, ctx, mapaRegras);
    }
}