public with sharing class PricingFacade {

    public static void calculatePricing(List<OrderItem> newItems) {

        Set<Id> orderIDs = new Set<Id>();
        Set<Id> productIDs = new Set<Id>();

        for (OrderItem item : newItems) {
            if (item.OrderId != null) orderIDs.add(item.OrderId);
            if (item.Product2Id != null) productIDs.add(item.Product2Id);
        }

        Map<Id, Order> mapOrder = new Map<Id, Order>([
            SELECT Id,
                   AccountId,
                   Account.AccountGroup__c,
                   DistributionCenter__c,
                   Address__r.City__c,
                   Address__r.City__r.State__c,
                   Address__r.City__r.State__r.Country__c
            FROM Order
            WHERE Id IN :orderIDs
        ]);

        Map<Id, Product2> mapProduct = new Map<Id, Product2>([
            SELECT Id,
                   ProductHierarchy__c
            FROM Product2
            WHERE Id IN :productIDs
        ]);

        PricingContext context = buildGlobalContext(newItems, mapOrder, mapProduct);

        List<IPricingEngine> engines = new List<IPricingEngine>{
            new FreightPricingEngine(),
            new MarginPricingEngine(),
            new TaxPricingEngine()
        };

        for (IPricingEngine engine : engines) {
            engine.calculatePrice(newItems, context);
        }
    }


    private static PricingContext buildGlobalContext(List<OrderItem> newItems, Map<Id, Order> mapOrder, Map<Id, Product2> mapProduct) {
        PricingContext globalContext = new PricingContext();

        globalContext.mapOrders   = mapOrder;
        globalContext.mapProducts = mapProduct;

        for (OrderItem item : newItems) {
            Order order      = mapOrder.get(item.OrderId);
            Product2 product = mapProduct.get(item.Product2Id);

            // --- FREIGHT ---
            globalContext.freight.productIds.add(item.Product2Id);

            if (product != null && product.ProductHierarchy__c != null) {
                globalContext.freight.hierarchyIds.add(product.ProductHierarchy__c);
            }
            if (order != null) {
                if (order.DistributionCenter__c != null) {
                    globalContext.freight.dcIds.add(order.DistributionCenter__c);
                }
                if (order.Address__r != null) {
                    if (order.Address__r.City__c != null) globalContext.freight.locationIds.add(order.Address__r.City__c);
                    if (order.Address__r.City__r?.State__c != null) globalContext.freight.locationIds.add(order.Address__r.City__r.State__c);
                    if (order.Address__r.City__r?.State__r?.Country__c != null) globalContext.freight.locationIds.add(order.Address__r.City__r.State__r.Country__c);
                }
            }

            // --- MARGIN ---
            globalContext.margin.productIds.add(item.Product2Id);

            if (product != null && product.ProductHierarchy__c != null) {
                globalContext.margin.hierarchyIds.add(product.ProductHierarchy__c);
            }
            if (order != null) {
                if (order.AccountId != null) globalContext.margin.accountIds.add(order.AccountId);
                if (order.Account != null && order.Account.AccountGroup__c != null) {
                    globalContext.margin.accountGroupIds.add(order.Account.AccountGroup__c);
                }
                if (order.DistributionCenter__c != null) {
                    globalContext.margin.dcIds.add(order.DistributionCenter__c);
                }
                if (order.Address__r != null) {
                    if (order.Address__r.City__c != null) globalContext.margin.locationIds.add(order.Address__r.City__c);
                    if (order.Address__r.City__r?.State__c != null) globalContext.margin.locationIds.add(order.Address__r.City__r.State__c);
                    if (order.Address__r.City__r?.State__r?.Country__c != null) globalContext.margin.locationIds.add(order.Address__r.City__r.State__r.Country__c);
                }
            }

            // --- TAX ---
            globalContext.tax.productIds.add(item.Product2Id);

            if (order != null) {
                if (order.DistributionCenter__c != null) {
                    globalContext.tax.dcIds.add(order.DistributionCenter__c);
                }
                if (order.Address__r != null && order.Address__r.City__r?.State__c != null) {
                    globalContext.tax.locationIds.add(order.Address__r.City__r.State__c);
                }
            }
        }

        return globalContext;
    }

}
