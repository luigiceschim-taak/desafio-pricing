public with sharing class TaxPricingEngine implements IPricingEngine {

    public void calculatePrice(List<OrderItem> items, PricingContext context) {
        Map<String, Tax__c> rulesMap = TaxSelector.getRulesMap(
            context.tax.productIds,
            context.tax.locationIds,
            context.tax.dcIds
        );
        TaxEngine engine = new TaxEngine(rulesMap);

        for (OrderItem item : items) {
            Order order = context.mapOrders.get(item.OrderId);
            TaxContext ctx = new TaxContext(item, order);
            Tax__c result = engine.find(ctx);

            if (result != null) {
                item.TaxPercentage__c = result.TaxCost__c;
            } else {
                item.addError('Error: Tax rule not found. Sale of this product is not authorized due to missing pricing parameters. Contact the Pricing team.');
            }
        }
    }

}
