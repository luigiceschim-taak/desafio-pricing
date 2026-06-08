public with sharing class OrderService {

    private static final Map<String, Set<String>> STATUS_TRANSITIONS = new Map<String, Set<String>>{
        'New'            => new Set<String>{'PendingApproval', 'New'},
        'PendingApproval' => new Set<String>{'Approved', 'New'},
        'Approved'         => new Set<String>{'Integrated', 'IntegrationError'},
        'IntegrationError' => new Set<String>{'Integrated', 'IntegrationError'},
        'Integrated'       => new Set<String>()
    };

    public static void validateOrderEdit(List<Order> orders, Map<Id, Order> oldOrders) {
        for (Order o : orders) {
            Order oldOrder = oldOrders.get(o.Id);
            if (oldOrder == null) continue;

            if (oldOrder.Status != 'New') {
                if (o.AccountId            != oldOrder.AccountId            ||
                    o.Address__c           != oldOrder.Address__c           ||
                    o.DistributionCenter__c != oldOrder.DistributionCenter__c ||
                    o.Pricebook2Id         != oldOrder.Pricebook2Id         ||
                    o.EffectiveDate        != oldOrder.EffectiveDate) {
                    o.addError('Orders outside "New" status cannot be edited.');
                }
               continue;
            }

            
        }
    }

    public static void validateStatus(List<Order> newOrdersList, Map<Id, Order> oldOrdersList) {
        Set<Id> orderIds = new Set<Id>();
        for (Order o : newOrdersList) orderIds.add(o.Id);

        // Relações filhas não vêm carregadas no contexto de trigger update (ex.: recálculo
        // disparado ao inserir um OrderItem), então IOrder.OrderItems seria sempre vazio.
        // Conta os itens reais no banco para a validação ser confiável.
        Map<Id, Integer> itemCountByOrder = new Map<Id, Integer>();
        for (AggregateResult ar : [
                SELECT OrderId oid, COUNT(Id) cnt
                FROM OrderItem
                WHERE OrderId IN :orderIds
                GROUP BY OrderId]) {
            itemCountByOrder.put((Id) ar.get('oid'), (Integer) ar.get('cnt'));
        }

        for (Order IOrder : newOrdersList) {
            Order oldOrder = oldOrdersList.get(IOrder.Id);
            if (oldOrder == null) continue;

            Integer itemCount = itemCountByOrder.containsKey(IOrder.Id) ? itemCountByOrder.get(IOrder.Id) : 0;

            // New -> New (adicionar itens, recalcular, movimentar) é permitido.
            // Só não pode SAIR para outro status com o pedido sem nenhum item.
            if (oldOrder.Status != IOrder.Status && itemCount == 0) {
                IOrder.addError('Order must have at least one Order Item before changing status.');
            }

            Set<String> allowed = STATUS_TRANSITIONS.get(oldOrder.Status);
            if (allowed == null || allowed.contains(IOrder.Status)) continue;

            IOrder.addError('Status transition from "' + oldOrder.Status + '" to "' + IOrder.Status + '" is not allowed.');
        }
    }

    public static void updateOrderItems(List<Order> orders, Map<Id, Order> oldOrders) {
        if (TriggerControl.isRecalculating) return;
        Set<Id> changedOrderIds = new Set<Id>();

        for (Order o : orders) {
            Order oldOrder = oldOrders.get(o.Id);
            if (o.Status != 'New') continue;
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
            if (oldOrder == null) continue;
            Set<String> allowed = STATUS_TRANSITIONS.get(oldOrder.Status);
            if (allowed != null && allowed.contains(o.Status) && o.Status == 'Approved') {
                activeOrderIds.add(o.Id);
            }
        }

        if (!activeOrderIds.isEmpty()) {
            CalloutOrder.executeCalloutOrderAsync(activeOrderIds);
        }
    }


}
