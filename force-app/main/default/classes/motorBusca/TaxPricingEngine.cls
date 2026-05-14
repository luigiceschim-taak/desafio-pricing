public with sharing class TaxPricingEngine implements IPricingEngine {

    public void calculatePrice(List<OrderItem> itens, PricingContext context) {
        Map<String, Tax__c> mapaRegras = TaxSelector.getMapaRegras(
            context.imposto.produtosIds,
            context.imposto.locaisIds,
            context.imposto.cdsIds
        );
        TaxEngine motor = new TaxEngine(mapaRegras);

        for (OrderItem item : itens) {
            Order ped = context.mapPedidos.get(item.OrderId);
            TaxContext ctx = new TaxContext(item, ped);
            Tax__c resultado = motor.buscar(ctx);

            if (resultado != null) {
                item.TaxPercentage__c = resultado.TaxCost__c;
            } else {
                item.addError('Erro: Imposto não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        }
    }

}