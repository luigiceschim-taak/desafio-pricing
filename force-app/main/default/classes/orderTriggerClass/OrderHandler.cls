public with sharing class OrderHandler extends OrderTriggerHandler {
    public OrderHandler() {

    }

    public override void beforeUpdate() {
        OrderService.validateOrderEdit((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
        OrderService.validateStatus((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }

    public override void afterUpdate() {
        OrderService.updateOrderItems((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
        OrderService.calloutStatusActive((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }




}
