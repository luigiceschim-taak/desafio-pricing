public with sharing class PricingFacade {

    public static void calcularPricing(List<OrderItem> newItens) {

        Set<Id> orderIDs = new Set<Id>();
        Set<Id> productIDs = new Set<Id>();

        for (OrderItem item : newItens) {
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

        PricingContext context = generateGeneralContext(newItens, mapOrder, mapProduct);

        List<IPricingEngine> engines = new List<IPricingEngine>{
            new FreightPricingEngine(),
            new MarginPricingEngine(),
            new TaxPricingEngine()
        };

        for (IPricingEngine engine : engines) {
            engine.calculatePrice(newItens, context);
        }
    }


    private static PricingContext generateGeneralContext(List<OrderItem> newItens, Map<Id, Order> mapOrder, Map<Id, Product2> mapProduct) {
        PricingContext contextoGeral = new PricingContext();

        contextoGeral.mapPedidos  = mapOrder;
        contextoGeral.mapProdutos = mapProduct;

        for (OrderItem item : newItens) {
            Order order     = mapOrder.get(item.OrderId);
            Product2 product = mapProduct.get(item.Product2Id);

            // --- Malinha de FRETE ---
            contextoGeral.frete.produtosIds.add(item.Product2Id);

            if (product != null && product.ProductHierarchy__c != null) {
                contextoGeral.frete.hierarquiasIds.add(product.ProductHierarchy__c);
            }
            if (order != null) {
                if (order.DistributionCenter__c != null) {
                    contextoGeral.frete.cdsIds.add(order.DistributionCenter__c);
                }
                if (order.Address__r != null) {
                    if (order.Address__r.City__c != null) contextoGeral.frete.locaisIds.add(order.Address__r.City__c);
                    if (order.Address__r.City__r?.State__c != null) contextoGeral.frete.locaisIds.add(order.Address__r.City__r.State__c);
                    if (order.Address__r.City__r?.State__r?.Country__c != null) contextoGeral.frete.locaisIds.add(order.Address__r.City__r.State__r.Country__c);
                }
            }

            // --- Malinha de MARGEM ---
            contextoGeral.margem.produtosIds.add(item.Product2Id);

            if (product != null && product.ProductHierarchy__c != null) {
                contextoGeral.margem.hierarquiasIds.add(product.ProductHierarchy__c);
            }
            if (order != null) {
                if (order.AccountId != null) contextoGeral.margem.contasIds.add(order.AccountId);
                if (order.Account != null && order.Account.AccountGroup__c != null) {
                    contextoGeral.margem.hContasIds.add(order.Account.AccountGroup__c);
                }
                if (order.DistributionCenter__c != null) {
                    contextoGeral.margem.cdsIds.add(order.DistributionCenter__c);
                }
                if (order.Address__r != null) {
                    if (order.Address__r.City__c != null) contextoGeral.margem.locaisIds.add(order.Address__r.City__c);
                    if (order.Address__r.City__r?.State__c != null) contextoGeral.margem.locaisIds.add(order.Address__r.City__r.State__c);
                    if (order.Address__r.City__r?.State__r?.Country__c != null) contextoGeral.margem.locaisIds.add(order.Address__r.City__r.State__r.Country__c);
                }
            }

            // --- Malinha de IMPOSTO ---
            contextoGeral.imposto.produtosIds.add(item.Product2Id);

            if (order != null) {
                if (order.DistributionCenter__c != null) {
                    contextoGeral.imposto.cdsIds.add(order.DistributionCenter__c);
                }
                if (order.Address__r != null && order.Address__r.City__r?.State__c != null) {
                    contextoGeral.imposto.locaisIds.add(order.Address__r.City__r.State__c);
                }
            }
        }

        return contextoGeral;
    }

}