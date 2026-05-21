public with sharing class OrderItemService {

    public static void recalculateOrder(List<OrderItem> items) {
        Set<Id> orderIds = new Set<Id>();
        for (OrderItem item : items) {
            if (item.OrderId != null) orderIds.add(item.OrderId);
        }
        if (orderIds.isEmpty()) return;

        // Re-query ALL items for the affected orders — not just the trigger batch
        List<OrderItem> allOrderItensFromOrders = [
            SELECT OrderId, TotalIdealPrice__c, TotalSellingPrice__c
            FROM OrderItem
            WHERE OrderId IN :orderIds
        ];

        Map<Id, List<OrderItem>> itemsByOrder = new Map<Id, List<OrderItem>>();
        for (Id IOrderIds : orderIds) itemsByOrder.put(IOrderIds, new List<OrderItem>());
        for (OrderItem IOrderItemList : allOrderItensFromOrders) itemsByOrder.get(IOrderItemList.OrderId).add(IOrderItemList);

        List<Order> ordersToUpdate = new List<Order>();
        for (Id orderId : orderIds) {
            Map<String, Object> pricing = calculateOrderPricing(itemsByOrder.get(orderId));
            ordersToUpdate.add(new Order(
                Id                     = orderId,
                Total_Ideal_Price__c   = (Decimal) pricing.get('Total_Ideal_Price__c'),
                Total_Actual_Price__c  = (Decimal) pricing.get('Total_Actual_Price__c'),
                Price_Impact__c        = (Decimal) pricing.get('Price_Impact__c'),
                Discount_Percentage__c = (Decimal) pricing.get('Discount_Percentage__c'),
                Profit_Percentage__c   = (Decimal) pricing.get('Profit_Percentage__c'),
                Price_Impact_Type__c   = (String)  pricing.get('Price_Impact_Type__c'),
                Approval_Process__c    = (Boolean) pricing.get('Approval_Process__c')
            ));
        }

        if (!ordersToUpdate.isEmpty()) update ordersToUpdate;
    }

    private static Map<String, Object> calculateOrderPricing(List<OrderItem> orderItems) {
        Decimal totalIdeal  = 0;
        Decimal totalActual = 0;

        for (OrderItem IOrderItens : orderItems) { 
            totalIdeal  += IOrderItens.TotalIdealPrice__c  != null ? IOrderItens.TotalIdealPrice__c  : 0;
            totalActual += IOrderItens.TotalSellingPrice__c != null ? IOrderItens.TotalSellingPrice__c : 0;
        }

        // positive = actual above ideal (profit); negative = actual below ideal (discount)
        Decimal priceImpact = totalActual - totalIdeal;

        String impactType;
        if      (priceImpact > 0) impactType = 'PROFIT';
        else if (priceImpact < 0) impactType = 'DISCOUNT';
        else                      impactType = 'NO_VARIANCE';

        Decimal pctBase     = totalIdeal != 0 ? (Math.abs(priceImpact) / totalIdeal) * 100 : 0;
        Decimal discountPct = Math.max(0, impactType == 'DISCOUNT' ? pctBase : 0);
        Decimal profitPct   = Math.max(0, impactType == 'PROFIT'   ? pctBase : 0);
        Boolean needsApproval = profitPct > 20 || discountPct > 20;

        Map<String, Object> result = new Map<String, Object>();
        result.put('Total_Ideal_Price__c',   totalIdeal);
        result.put('Total_Actual_Price__c',  totalActual);
        result.put('Price_Impact__c',        priceImpact);
        result.put('Discount_Percentage__c', discountPct);
        result.put('Profit_Percentage__c',   profitPct);
        result.put('Price_Impact_Type__c',   impactType);
        result.put('Approval_Process__c',    needsApproval);
        return result;
    }
}