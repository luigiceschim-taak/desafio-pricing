public with sharing class PedidoHandler extends PedidoTriggerHandler {
    public PedidoHandler() {

    }

    public override void beforeUpdate() {
        // Lógica específica para before update
        
        System.debug('Executando lógica de before update');
        PedidoService.validarStatusPedido((List<Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);

        PedidoService.naoPermitirEdicaoPedido((List <Order>) Trigger.new, (Map<Id, Order>) Trigger.oldMap);

    }

    public override void afterUpdate(){
        // Lógica específica para after update
        System.debug('Executando lógica de after update');
        PedidoService.atualizarOrderItens((List<Order>) Trigger.new , (Map<Id, Order>) Trigger.oldMap);

            
    }

    


    
    

   
    
}