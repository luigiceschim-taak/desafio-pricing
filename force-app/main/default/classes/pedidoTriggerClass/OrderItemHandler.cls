public class OrderItemHandler extends TriggerHandler {

    public override void afterInsert() {
        mesclarItensExistentes((List<OrderItem>) Trigger.new);
    }

    public override void beforeInsert(){
        resgatarImpostoParaItem((List<OrderItem>) Trigger.new);
        resgatarValorFreteParaItem((List<OrderItem>) Trigger.new);
        resgatarMargemParaItem((List<OrderItem>) Trigger.new);
        custoDeProd((List<OrderItem>) Trigger.new);

    }

    public override void beforeUpdate(){
        resgatarImpostoParaItem((List<OrderItem>) Trigger.new);
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

    private void resgatarImpostoParaItem(List<OrderItem> novosItens){
        
        Set<Id> produtosIds = new Set<Id>();
        Set<Id> pedidosId = new Set<Id>();
        
        for (OrderItem item : novosItens) {
            if (item.Product2Id != null) {
                produtosIds.add(item.Product2Id);
                pedidosId.add(item.OrderId);
            }
        }
        if (produtosIds.isEmpty()) return;

        Map<Id, Order> mapaPedidos = new Map<Id, Order>([
        SELECT Id, Centro_Distribuicao__c FROM Order WHERE Id IN :pedidosId
        ]);

        // Coletamos os IDs dos CDs envolvidos para filtrar a query de impostos
        Set<Id> cdsIds = new Set<Id>();
        for (Order ord : mapaPedidos.values()) {
            if (ord.Centro_Distribuicao__c != null) {
                cdsIds.add(ord.Centro_Distribuicao__c);
            }
        }


        Map<String, Imposto__c> mapaImpostos = new Map<String, Imposto__c>();

        for(Imposto__c impo : [
            SELECT Id, Imposto_Custo__c, Product__c, Centro_Distribuicao__c 
            FROM Imposto__c 
            WHERE Product__c IN :produtosIds 
            AND Status__c = 'Aprovado' 
            AND Centro_Distribuicao__c IN :cdsIds
            ]){

            String chave = (String)impo.Product__c + (String)impo.Centro_Distribuicao__c;
            mapaImpostos.put(chave, impo);
        }

        for (OrderItem item : novosItens) {
        Order pedidoPai = mapaPedidos.get(item.OrderId);
        
            if (pedidoPai != null && pedidoPai.Centro_Distribuicao__c != null) {
                String chaveBusca = (String)item.Product2Id + (String)pedidoPai.Centro_Distribuicao__c;
                
                if (mapaImpostos.containsKey(chaveBusca)) {
                    item.Porcentagem_Imposto__c = mapaImpostos.get(chaveBusca).Imposto_Custo__c;
                    System.debug('Imposto encontrado :' + mapaImpostos.get(chaveBusca).Imposto_Custo__c);
                } else {
                    // Caso não encontre, você pode definir um valor padrão ou logar um aviso
                    System.debug('Aviso: Nenhum imposto encontrado para o Produto ' + item.Product2Id + ' no CD ' + pedidoPai.Centro_Distribuicao__c);
                    item.addError('Erro: não há imposto para este produto. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing. ');
                }
            }
        }
    }

    private void resgatarValorFreteParaItem(List<OrderItem> novosItens){
        System.debug('iniciando');

        Set<Id> produtosIds = new Set<Id>();
        Set<Id> pedidosIds = new Set<Id>();
        Set<Id> hierarquiasIds = new Set<Id>();
       
    
        for (OrderItem item : novosItens) {
            if (item.Product2Id != null) {
                produtosIds.add(item.Product2Id);
                pedidosIds.add(item.OrderId);
                System.debug(item.Product2Id);
                System.debug(item.OrderId);
            }
        }

        Map<Id, Product2> mapaProdutosParaHierarquia = new Map<Id, Product2>([
            SELECT Id, Hierarquia_Produto__c FROM Product2 WHERE Id IN :produtosIds
        ]);

        
        for (Product2 p : mapaProdutosParaHierarquia.values()) {
            if (p.Hierarquia_Produto__c != null) {
                System.debug('hierarquia: ' + p.Hierarquia_Produto__c);
                hierarquiasIds.add(p.Hierarquia_Produto__c);
            }
        }


        if (produtosIds.isEmpty()) return;

        // 1. Buscamos o Pedido "subindo" a escada da Cidade para pegar Estado e Pais
        Map<Id, Order> mapaPedidos = new Map<Id, Order>([
            SELECT Id, 
            Endereco__r.Cidade__c, 
            Endereco__r.Cidade__r.Estado__c, 
            Endereco__r.Cidade__r.Estado__r.Pais__c 
            FROM Order 
            WHERE Id IN :pedidosIds
            ]);

        // 2. Criamos o Mapa de Regras com Chave Composta (Alvo + Localidade)
        Map<String, Frete__c> mapaRegras = new Map<String, Frete__c>();
        
        // Buscamos fretes que sejam de Produtos OU de Hierarquias
        for (Frete__c f : [
            SELECT Valor__c, Produto__c, Hierarquia_Produto__c, Cidade__c, Estado__c, Pais__c 
            FROM Frete__c 
            WHERE Status__c = 'Aprovado'
            AND (Produto__c IN :produtosIds OR Hierarquia_Produto__c IN :hierarquiasIds)
        ]) {
            // Define o ID do "Alvo" (Produto ou Hierarquia)
            Id alvoId = (f.Produto__c != null) ? f.Produto__c : f.Hierarquia_Produto__c;
            
            // Define a localidade da regra (ID da Cidade, Estado ou Pais)
            Id locId = (f.Cidade__c != null) ? f.Cidade__c : 
                    (f.Estado__c != null) ? f.Estado__c : f.Pais__c;

            if (alvoId != null && locId != null) {
                mapaRegras.put((String)alvoId + (String)locId, f);
            }
        }

        System.debug(mapaRegras.values());

        // 3. O "Motor" de Busca em Cascata
        for (OrderItem item : novosItens) {
            Order ped = mapaPedidos.get(item.OrderId);
            if (ped == null || ped.Endereco__r.Cidade__c == null) continue;

            Product2 prodDados = mapaProdutosParaHierarquia.get(item.Product2Id);

            Id pId = item.Product2Id;
            Id hId = (prodDados != null) ? prodDados.Hierarquia_Produto__c : null; // Certifique-se que esse campo existe no Item
            
            // IDs extraídos via Navegação de Ponto (__r)
            Id cidId = ped.Endereco__r.Cidade__c;
            Id estId = ped.Endereco__r.Cidade__r.Estado__c;
            Id paiId = ped.Endereco__r.Cidade__r.Estado__r.Pais__c;

            Frete__c match = null;

            // --- A SEQUÊNCIA DE TENTATIVAS (CASCATA) ---
            
            // Tenta PRODUTO + Localidade
            if (mapaRegras.containsKey((String)pId + cidId))      match = mapaRegras.get((String)pId + cidId);
            else if (mapaRegras.containsKey((String)pId + estId)) match = mapaRegras.get((String)pId + estId);
            else if (mapaRegras.containsKey((String)pId + paiId)) match = mapaRegras.get((String)pId + paiId);
            
            // Se não achou, tenta HIERARQUIA + Localidade
            else if (hId != null) {
                if (mapaRegras.containsKey((String)hId + cidId))      match = mapaRegras.get((String)hId + cidId);
                else if (mapaRegras.containsKey((String)hId + estId)) match = mapaRegras.get((String)hId + estId);
                else if (mapaRegras.containsKey((String)hId + paiId)) match = mapaRegras.get((String)hId + paiId);
            }

            if (match != null) {
                System.debug(match);
                item.Valor_Frete__c = match.Valor__c;
                System.debug('Valor do frete encontrado para o item ' + item.Id + ': ' + match.Valor__c +item.Valor_Frete__c);
            }else{
                System.debug('Aviso: Nenhum frete encontrado para o Produto ' + item.Product2Id + ' no CD ' + ped.Centro_Distribuicao__c );
                item.addError('ERRO: Não há frete encontrado. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
            }
        
        }
    }

    private void resgatarMargemParaItem(List<OrderItem> novosItens) {
    Set<Id> produtosIds = new Set<Id>();
    Set<Id> pedidosIds = new Set<Id>();
    
    for (OrderItem item : novosItens) {
        if (item.Product2Id != null) {
            produtosIds.add(item.Product2Id);
            pedidosIds.add(item.OrderId);
        }
    }
    if (produtosIds.isEmpty()) return;

    // 1. Hierarquias dos Produtos
    Map<Id, Product2> mapaProdutos = new Map<Id, Product2>([
        SELECT Id, Hierarquia_Produto__c FROM Product2 WHERE Id IN :produtosIds
    ]);
    
    Set<Id> hierarquiasIds = new Set<Id>();
    for (Product2 p : mapaProdutos.values()) {
        if (p.Hierarquia_Produto__c != null) hierarquiasIds.add(p.Hierarquia_Produto__c);
    }

    // 2. Dados do Pedido (Cliente, Grupo e Localidade)
    Map<Id, Order> mapaPedidos = new Map<Id, Order>([
        SELECT Id, AccountId, Account.Grupo_Clientes__c, Endereco__c,
               Endereco__r.Cidade__c, 
               Endereco__r.Cidade__r.Estado__c, 
               Endereco__r.Cidade__r.Estado__r.Pais__c
        FROM Order WHERE Id IN :pedidosIds
    ]);

    // 3. Mapa de Regras de Margem
    Map<String, Margem__c> mapaRegras = new Map<String, Margem__c>();
    
    for (Margem__c m : [
        SELECT Valor__c, Produto__c, Hierarquia_Produto__c, 
               Conta__c, Grupo_Conta__c, Cidade__c, Estado__c, Pais__c 
        FROM Margem__c 
        WHERE Status__c = 'Aprovado'
        AND (Produto__c IN :produtosIds OR Hierarquia_Produto__c IN :hierarquiasIds OR Produto__c = null)
    ]) {
        Id alvoId = (m.Produto__c != null) ? m.Produto__c : m.Hierarquia_Produto__c;
        Id cliId  = (m.Conta__c != null) ? m.Conta__c : m.Grupo_Conta__c;
        Id locId  = (m.Cidade__c != null) ? m.Cidade__c : (m.Estado__c != null ? m.Estado__c : m.Pais__c);
        
        if (alvoId != null && cliId != null && locId != null) {
            mapaRegras.put((String)alvoId + (String)cliId + (String)locId, m);
        }
    }

    // 4. Motor de Busca (Usando Boolean em vez de Label)
    for (OrderItem item : novosItens) {
        Order ped = mapaPedidos.get(item.OrderId);
        Product2 prod = mapaProdutos.get(item.Product2Id);
        if (ped == null || prod == null || ped.Endereco__c == null) continue;

        // Listas de Prioridade (O primeiro da lista é o mais importante)
        List<Id> prods = new List<Id>{ prod.Id, prod.Hierarquia_Produto__c };
        List<Id> clis  = new List<Id>{ ped.AccountId, ped.Account.Grupo_Clientes__c };
        List<Id> locs  = new List<Id>{ 
            ped.Endereco__r.Cidade__c, 
            ped.Endereco__r.Cidade__r.Estado__c, 
            ped.Endereco__r.Cidade__r.Estado__r.Pais__c 
        };

        Margem__c match = null;
        Boolean encontrou = false; // Nossa "bandeira" para parar os loops

        for (Id p : prods) {
            if (p == null || encontrou) break; 
            
            for (Id c : clis) {
                if (c == null || encontrou) break;
                
                for (Id l : locs) {
                    if (l == null) continue;
                    
                    String chave = (String)p + (String)c + (String)l;
                    
                    if (mapaRegras.containsKey(chave)) {
                        match = mapaRegras.get(chave);
                        encontrou = true; // Ativa a bandeira
                        break; // Sai do loop da localidade
                    }
                }
            }
        }

        if (match != null) {
            item.Porcentagem_Margem__c = match.Valor__c;
        }else{
            item.addError('Erro: Margem não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');
        }
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
                SELECT Id, Custo_Producao__c 
                FROM Product2 
                WHERE Id IN :produtosIds
            ]); 

            for (OrderItem item : novosItens){
                if(mapaProdutos.containsKey(item.Product2Id)){
                    item.Custo_Producao__c = mapaProdutos.get(item.Product2Id).Custo_Producao__c;
                }

            }
    }        



}