public class OrderItemHandler extends TriggerHandler {

    public override void afterInsert() {
        mergeExistingItems((List<OrderItem>) Trigger.new);
        OrderItemService.recalculateOrder((List<OrderItem>) Trigger.new);
    }

    public override void afterUpdate() {
        OrderItemService.recalculateOrder((List<OrderItem>) Trigger.new);
    }

    public override void beforeInsert(){
        PricingFacade.calculatePricing((List<OrderItem>) Trigger.new);
        setProductionCost((List<OrderItem>) Trigger.new);
    }

    public override void beforeUpdate(){
        validateOrderStatus((List<OrderItem>) Trigger.new);
        PricingFacade.calculatePricing((List<OrderItem>) Trigger.new);
    }

    private void mergeExistingItems(List<OrderItem> newItems) {
        Set<Id> productIds  = new Set<Id>();
        Set<Id> orderIds    = new Set<Id>();
        Set<Id> newItemIds  = new Set<Id>();

        for (OrderItem item : newItems) {
            productIds.add(item.Product2Id);
            orderIds.add(item.OrderId);
            newItemIds.add(item.Id);
        }

        List<OrderItem> oldItems = [SELECT Id, Quantity, Product2Id, OrderId
                                        FROM OrderItem
                                        WHERE OrderId IN :orderIds
                                        AND Product2Id IN :productIds
                                        AND Id NOT IN :newItemIds];

        if (oldItems.isEmpty()) return;

        Map<String, OrderItem> oldItemsMap = new Map<String, OrderItem>();
        for (OrderItem oldItem : oldItems) {
            oldItemsMap.put(oldItem.OrderId + '-' + oldItem.Product2Id, oldItem);
        }

        List<OrderItem> toUpdate = new List<OrderItem>();
        List<OrderItem> toDelete = new List<OrderItem>();

        for (OrderItem newItem : newItems) {
            String key = newItem.OrderId + '-' + newItem.Product2Id;

            if (oldItemsMap.containsKey(key)) {
                OrderItem oldItem = oldItemsMap.get(key);

                oldItem.Quantity += newItem.Quantity;
                toUpdate.add(oldItem);

                toDelete.add(new OrderItem(Id = newItem.Id));
            }
        }

        if (!toUpdate.isEmpty() || !toDelete.isEmpty()) {
            if (!toUpdate.isEmpty()) update toUpdate;
            if (!toDelete.isEmpty()) delete toDelete;
        }
    }


    private void setProductionCost(List<OrderItem> newItems){

            Set<Id> productIds = new Set<Id>();
            Set<Id> orderIds   = new Set<Id>();

            for (OrderItem item : newItems) {
                if (item.Product2Id != null) {
                    productIds.add(item.Product2Id);
                    orderIds.add(item.OrderId);
                }
            }
            if (productIds.isEmpty()) return;

            Map<Id, Product2> productsMap = new Map<Id,Product2>([
                SELECT Id, ProductionCost__c
                FROM Product2
                WHERE Id IN :productIds
            ]);

            for (OrderItem item : newItems){
                if(productsMap.containsKey(item.Product2Id)){
                    item.ProductionCost__c = productsMap.get(item.Product2Id).ProductionCost__c;
                }

            }
    }

    private void validateOrderStatus(List<OrderItem> items){
        Set<Id> orderIds = new Set<Id>();

        for (OrderItem item : items) {
            orderIds.add(item.OrderId);
        }

        Map<Id, Order> ordersMap = new Map<Id, Order>([
            SELECT Id, Status FROM Order WHERE Id IN :orderIds
        ]);

        for (OrderItem item : items) {
            Order order = ordersMap.get(item.OrderId);
            if (order != null && order.Status == 'Activated') {
                item.addError('Error: Items of an active order cannot be changed.');
            }
        }
    }




}
