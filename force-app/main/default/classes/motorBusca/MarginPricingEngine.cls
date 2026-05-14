public class MarginPricingEngine implements IPricingEngine {

    public void calculatePrice(List<OrderItem> itens, PricingContext context) {
        Map<String, Margin__c> mapaRegras = MarginSelector.getMapaRegras(
            context.margem.produtosIds,
            context.margem.hierarquiasIds,
            context.margem.locaisIds,
            context.margem.cdsIds,
            context.margem.contasIds,
            context.margem.hContasIds
        );
        MarginEngine motor = new MarginEngine(mapaRegras);

        for (OrderItem item : itens) {
            Order ped = context.mapPedidos.get(item.OrderId);
            Id hId = context.mapProdutos.get(item.Product2Id)?.ProductHierarchy__c;
            MarginContext ctx = new MarginContext(item, ped, hId);
            Margin__c resultado = motor.buscar(ctx);

            if (resultado != null) {
                item.MarginPercentage__c = resultado.Cost__c;
            } else {
                item.addError('Erro: Margem não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }

}