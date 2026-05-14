public class FreightPricingEngine implements IPricingEngine {

    public void calculatePrice(List<OrderItem> itens, PricingContext context) {
        Map<String, Freight__c> mapaRegras = FreightSelector.getMapaRegras(
            context.frete.produtosIds,
            context.frete.hierarquiasIds,
            context.frete.locaisIds,
            context.frete.cdsIds
        );
        FreightEngine motor = new FreightEngine(mapaRegras);

        for (OrderItem item : itens) {
            Order ped = context.mapPedidos.get(item.OrderId);
            Id hId = context.mapProdutos.get(item.Product2Id)?.ProductHierarchy__c;
            FreightContext ctx = new FreightContext(item, ped, hId);
            Freight__c resultado = motor.buscar(ctx);

            if (resultado != null) {
                item.FreightCost__c = resultado.Cost__c;
            } else {
                item.addError('Erro: Frete não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }

}