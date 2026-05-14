public class OrderItemHandler extends TriggerHandler {

    public override void afterInsert() {
        mesclarItensExistentes((List<OrderItem>) Trigger.new);
    }

    public override void beforeInsert(){
        PricingFacade.calcularPricing((List<OrderItem>) Trigger.new);
        custoDeProd((List<OrderItem>) Trigger.new);
    }

    public override void beforeUpdate(){
        validarStatusPedido((List<OrderItem>) Trigger.new);
        PricingFacade.calcularPricing((List<OrderItem>) Trigger.new);
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
            
            if (!paraAtualizar.isEmpty()) update paraAtualizar;
            if (!paraDeletar.isEmpty()) delete paraDeletar;
            
            
            
        }
    }

    
    private void custoDeProd(List<OrderItem> novosItens){

            Set<Id> produtosIds = new Set<Id>();
            Set<Id> pedidosIds = new Set<Id>();

            for (OrderItem item : novosItens) {
                if (item.Product2Id != null) {
                    produtosIds.add(item.Product2Id);
                    pedidosIds.add(item.OrderId);
                }
            }
            if (produtosIds.isEmpty()) return;

            Map<Id, Product2> mapaProdutos = new Map<Id,Product2>([
                SELECT Id, ProductionCost__c
                FROM Product2
                WHERE Id IN :produtosIds
            ]);

            for (OrderItem item : novosItens){
                if(mapaProdutos.containsKey(item.Product2Id)){
                    item.ProductionCost__c = mapaProdutos.get(item.Product2Id).ProductionCost__c;
                }

            }
    }   
    
    private void validarStatusPedido(List<OrderItem> itens){
        Set<Id> pedidosIds = new Set<Id>();

        for (OrderItem item : itens) {
            pedidosIds.add(item.OrderId);
        }

        Map<Id, Order> mapaPedidos = new Map<Id, Order>([
            SELECT Id, Status FROM Order WHERE Id IN :pedidosIds
        ]);

        System.debug('Validando status dos pedidos para os itens. Pedidos envolvidos: ' + mapaPedidos.keySet());

        for (OrderItem item : itens) {
            Order ped = mapaPedidos.get(item.OrderId);
            if (ped != null && ped.Status == 'Ativo') {
                item.addError('Erro: Itens de um pedido ativo não podem ser alterados.');
            }
        }
    }

    


}