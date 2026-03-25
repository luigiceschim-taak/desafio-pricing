public class OrderItemHandler extends TriggerHandler {

    public override void afterInsert() {
        mesclarItensExistentes((List<OrderItem>) Trigger.new);
    }

    private void mesclarItensExistentes(List<OrderItem> novosItens) {
        Set<Id> produtosIds = new Set<Id>();
        Set<Id> pedidoIds = new Set<Id>();
        Set<Id> novosItensIds = new Set<Id>();

        for (OrderItem item : novosItens) {
            produtosIds.add(item.Product2Id);
            pedidoIds.add(item.OrderId);
            novosItensIds.add(item.Id); // ID do "novo item"
        }

        // Busca os itens "antigos" (que não são os que acabaram de ser inseridos)
        List<OrderItem> itensAntigos = [SELECT Id, Quantity, Product2Id, OrderId 
                                        FROM OrderItem 
                                        WHERE OrderId IN :pedidoIds 
                                        AND Product2Id IN :produtosIds 
                                        AND Id NOT IN :novosItensIds];

        if (itensAntigos.isEmpty()) return;

        Map<String, OrderItem> mapaAntigos = new Map<String, OrderItem>();
        for (OrderItem antigo : itensAntigos) {
            mapaAntigos.put(antigo.OrderId + '-' + antigo.Product2Id, antigo);
        }

        List<OrderItem> paraAtualizar = new List<OrderItem>();
        List<OrderItem> paraDeletar = new List<OrderItem>();

        for (OrderItem novo : novosItens) {
            String chave = novo.OrderId + '-' + novo.Product2Id;
            
            if (mapaAntigos.containsKey(chave)) {
                OrderItem antigo = mapaAntigos.get(chave);
                
                // Soma a quantidade no antigo
                antigo.Quantity += novo.Quantity;
                paraAtualizar.add(antigo);

                // Marca o novo (duplicado) para sumir
                paraDeletar.add(new OrderItem(Id = novo.Id));
            }
        }

        // Executa as operações no banco com Bypass para evitar loop
        if (!paraAtualizar.isEmpty() || !paraDeletar.isEmpty()) {
            OrderItemHandler.bypass('OrderItemHandler');
            
            if (!paraAtualizar.isEmpty()) update paraAtualizar;
            if (!paraDeletar.isEmpty()) delete paraDeletar;
            
            OrderItemHandler.clearBypass('OrderItemHandler');
        }
    }
}
