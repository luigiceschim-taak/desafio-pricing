public with sharing class OrderHandler extends OrderTriggerHandler {
    public OrderHandler() {

    }

    public override void beforeUpdate() {
        // Lógica específica para before update

        System.debug('Executando lógica de before update');
        OrderService.validarStatusPedido((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);

        OrderService.naoPermitirEdicaoPedido((List <Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);

    }

    public override void afterUpdate(){
        // Lógica específica para after update
        System.debug('Executando lógica de after update');
        OrderService.atualizarOrderItens((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);
    }




}