public with sharing class PedidoService {
    public PedidoService() {

    }


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
        // Impede que pedidos com status "ATIVO" sejam editados, ele observa apenas o que esta mandando!


        for(Order o : pedidos) {
            Order oldOrder = pedidosAntigos.get(o.Id);
            if (oldOrder != null && oldOrder.Status == 'ATIVO') {
                o.addError('Pedidos com status "ATIVO" não podem ser editados.');
            }
        }
    }
    public static void atualizarOrderItens(List<Order> pedidos, Map<Id, Order> pedidosAntigos) {
        Set<Id> pedidosComAlteracaoIds = new Set<Id>();

        // 1. Identificar quais pedidos realmente mudaram (Filtragem)
        for (Order o : pedidos) {
            Order oldOrder = pedidosAntigos.get(o.Id);
            if (o.Endereco__c != oldOrder.Endereco__c || o.Centro_Distribuicao__c != oldOrder.Centro_Distribuicao__c) {
                pedidosComAlteracaoIds.add(o.Id);
            }
        }

        // Se ninguém mudou nada relevante, encerra aqui para poupar recursos
        if (pedidosComAlteracaoIds.isEmpty()) return;

        // 2. Query única para buscar TODOS os itens dos pedidos afetados
        List<OrderItem> itensParaAtualizar = [
            SELECT Id, Product2Id, OrderId 
            FROM OrderItem 
            WHERE OrderId IN :pedidosComAlteracaoIds
        ];

        if (!itensParaAtualizar.isEmpty()) {
            // 3. Executa a lógica de busca de frete uma única vez para todos os itens
            system.debug('Executando motores de busca em lote');
            MotorBusca.resgatarValorFrete(itensParaAtualizar);
            MotorBusca.resgatarValorImposto(itensParaAtualizar);

            // 4. DML único para atualizar todos os registros de uma vez
            update itensParaAtualizar;
        }
    }


}