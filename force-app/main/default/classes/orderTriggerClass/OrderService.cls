public with sharing class OrderService {

    public static void preventOrderEdit(List<Order> newOrders, Map<Id, Order> oldOrders){
       for(Order o : newOrders) {
           Order oldOrder = oldOrders.get(o.Id);
           if (oldOrder.AccountId != o.AccountId) {
               o.addError('Changing the Account on an order is not allowed.');
           }
       }
    }

    public static void validateIntegratedStatus(List<Order> orders, Map<Id, Order> oldOrders) {
        for (Order o : orders) {
            Order oldOrder = oldOrders.get(o.Id);
            if (oldOrder == null) continue;

            if (oldOrder.Status == 'Integrated') {
                if (o.AccountId    != oldOrder.AccountId    ||
                    o.Pricebook2Id != oldOrder.Pricebook2Id ||
                    o.EffectiveDate != oldOrder.EffectiveDate ||
                    o.Status       != oldOrder.Status) {
                    o.addError('Orders with status "INTEGRATED" cannot be edited.');
                }
            }

            if (oldOrder.Status == 'IntegrationError') {
                Boolean onlyRetry = (o.Status         == 'Approved'            &&
                                     o.AccountId      == oldOrder.AccountId    &&
                                     o.Pricebook2Id   == oldOrder.Pricebook2Id &&
                                     o.EffectiveDate  == oldOrder.EffectiveDate);
                if (!onlyRetry) {
                    o.addError('Orders with status "IntegrationError" can only be retried by changing the status to "Approved".');
                }
            }
        }
    }

    public static void updateOrderItems(List<Order> orders, Map<Id, Order> oldOrders) {
        if (TriggerControl.isRecalculating) return;
        Set<Id> changedOrderIds = new Set<Id>();

        for (Order o : orders) {
            Order oldOrder = oldOrders.get(o.Id);
            if (o.Address__c != oldOrder.Address__c || o.DistributionCenter__c != oldOrder.DistributionCenter__c) {
                changedOrderIds.add(o.Id);
            }
        }

        if (changedOrderIds.isEmpty()) return;

        List<OrderItem> itemsToUpdate = [
            SELECT Id, Product2Id, Product2.Id, Product2.ProductHierarchy__c, OrderId
            FROM OrderItem
            WHERE OrderId IN :changedOrderIds
        ];

        if (!itemsToUpdate.isEmpty()) {
            PricingFacade.calculatePricing(itemsToUpdate);

            Database.update(itemsToUpdate, false);
        }
    }

    public static void calloutStatusActive(List<Order> orders, Map<Id, Order> oldOrders) {
        List<String> activeOrderIds = new List<String>();

        for (Order o : orders) {
            Order oldOrder = oldOrders.get(o.Id);

            if (o.Status == 'Approved' && oldOrder.Status != 'Approved') {
                activeOrderIds.add(o.Id);
            }
        }

        if (!activeOrderIds.isEmpty()) {
            CalloutOrder.executeCalloutOrderAsync(activeOrderIds);
        }
    }


}
