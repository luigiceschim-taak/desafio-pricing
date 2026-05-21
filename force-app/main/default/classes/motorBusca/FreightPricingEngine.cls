public class FreightPricingEngine implements IPricingEngine {

    public void calculatePrice(List<OrderItem> items, PricingContext context) {
        Map<String, Freight__c> rulesMap = FreightSelector.getRulesMap(
            context.freight.productIds,
            context.freight.hierarchyIds,
            context.freight.locationIds,
            context.freight.dcIds
        );
        FreightEngine engine = new FreightEngine(rulesMap);

        for (OrderItem item : items) {
            Order order = context.mapOrders.get(item.OrderId);
            Id hId = context.mapProducts.get(item.Product2Id)?.ProductHierarchy__c;
            FreightContext ctx = new FreightContext(item, order, hId);
            Freight__c result = engine.find(ctx);

            if (result != null) {
                item.FreightCost__c = result.Cost__c;
            } else {
                item.addError('Error: Freight rule not found. Sale of this product is not authorized due to missing pricing parameters. Contact the Pricing team.');
            }
        }
    }

}
