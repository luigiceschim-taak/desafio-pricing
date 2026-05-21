public class MarginPricingEngine implements IPricingEngine {

    public void calculatePrice(List<OrderItem> items, PricingContext context) {
        Map<String, Margin__c> rulesMap = MarginSelector.getRulesMap(
            context.margin.productIds,
            context.margin.hierarchyIds,
            context.margin.locationIds,
            context.margin.dcIds,
            context.margin.accountIds,
            context.margin.accountGroupIds
        );
        MarginEngine engine = new MarginEngine(rulesMap);

        for (OrderItem item : items) {
            Order order = context.mapOrders.get(item.OrderId);
            Id hId = context.mapProducts.get(item.Product2Id)?.ProductHierarchy__c;
            MarginContext ctx = new MarginContext(item, order, hId);
            Margin__c result = engine.find(ctx);

            if (result != null) {
                item.MarginPercentage__c = result.Cost__c;
            } else {
                item.addError('Error: Margin rule not found. Sale of this product is not authorized due to missing pricing parameters. Contact the Pricing team.');
            }
        }
    }

}
