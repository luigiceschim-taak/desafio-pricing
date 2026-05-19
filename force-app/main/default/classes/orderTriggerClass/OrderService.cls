public with sharing class OrderService {

    public static void naoPermitirEdicaoPedido(List<Order> novosPedidos, Map<Id, Order> pedidosAntigos){
        // Impede edição de pedidos (Order)
       for(Order o : novosPedidos) {
           Order oldOrder = pedidosAntigos.get(o.Id);
           if (oldOrder.AccountId != o.AccountId) {
               o.addError('Não é permitido alterar a Conta do pedido.');
           }
       }
    }

    public static void validarStatusPedido(List<Order> pedidos, Map<Id, Order> pedidosAntigos) {
        for(Order o : pedidos) {
            Order oldOrder = pedidosAntigos.get(o.Id);
            if (oldOrder != null && oldOrder.Status == 'Integrated') {
                if (o.AccountId != oldOrder.AccountId ||
                    o.Pricebook2Id != oldOrder.Pricebook2Id ||
                    o.EffectiveDate != oldOrder.EffectiveDate ||
                    o.Status != oldOrder.Status) {
                    o.addError('Pedidos com status "INTEGRADO" não podem ser editados.');
                }
            }
        }
    }
    public static void atualizarOrderItens(List<Order> pedidos, Map<Id, Order> pedidosAntigos) {
        if (TriggerControl.isRecalculating) return;
        Set<Id> pedidosComAlteracaoIds = new Set<Id>();

        // 1. Identificar quais pedidos realmente mudaram (Filtragem)
        for (Order o : pedidos) {
            Order oldOrder = pedidosAntigos.get(o.Id);
            if (o.Address__c != oldOrder.Address__c || o.DistributionCenter__c != oldOrder.DistributionCenter__c) {
                pedidosComAlteracaoIds.add(o.Id);
            }
        }

        // Se ninguém mudou nada relevante, encerra aqui para poupar recursos
        if (pedidosComAlteracaoIds.isEmpty()) return;

        // 2. Query única para buscar TODOS os itens dos pedidos afetados
        List<OrderItem> itensParaAtualizar = [
            SELECT Id, Product2Id, Product2.Id,Product2.ProductHierarchy__c, OrderId
            FROM OrderItem
            WHERE OrderId IN :pedidosComAlteracaoIds
        ];

        if (!itensParaAtualizar.isEmpty()) {
            PricingFacade.calcularPricing(itensParaAtualizar);

            Database.update(itensParaAtualizar, false);
        }
    }
    public static void calloutStatusActive(List<Order> orders, Map<Id, Order> oldOrders) {
        System.debug('### [calloutStatusActive] Início — total orders no batch: ' + orders.size());

        List<String> activeOrderIds = new List<String>();

        for (Order o : orders) {
            Order oldOrder = oldOrders.get(o.Id);
            System.debug('### [calloutStatusActive] Order Id: ' + o.Id + ' | Status novo: ' + o.Status + ' | Status antigo: ' + oldOrder.Status);

            if (o.Status == 'Integrated' && oldOrder.Status != 'Integrated') {
                System.debug('### [calloutStatusActive] Order QUALIFICOU para callout: ' + o.Id);
                activeOrderIds.add(o.Id);
            }
        }

        System.debug('### [calloutStatusActive] Total de orders para callout: ' + activeOrderIds.size());

        if (!activeOrderIds.isEmpty()) {
            System.debug('### [calloutStatusActive] Disparando @future com IDs: ' + activeOrderIds);
            CalloutOrder.executeCalloutOrderAsync(activeOrderIds);
        } else {
            System.debug('### [calloutStatusActive] Nenhum order qualificou — callout não disparado.');
        }
    }


}