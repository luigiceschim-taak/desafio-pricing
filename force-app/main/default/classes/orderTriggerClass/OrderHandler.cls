public with sharing class OrderHandler extends OrderTriggerHandler {
    public OrderHandler() {

    }

    public override void beforeUpdate() {
        OrderService.validarStatusPedido((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
        OrderService.naoPermitirEdicaoPedido((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }

    public override void afterUpdate() {
        System.debug('calloutStatusActive - Início');

        
        OrderService.atualizarOrderItens((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
        OrderService.calloutStatusActive((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }




}