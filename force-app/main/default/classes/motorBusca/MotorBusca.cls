public with sharing class MotorBusca {

    public static void resgatarValorFrete(List<OrderItem> novosItens) {
        // 1. Coleta de IDs (Bulkify)
        Set<Id> produtosIds = new Set<Id>();
        Set<Id> pedidosIds = new Set<Id>();
        Set<Id> hierarquiasIds = new Set<Id>();
        for (OrderItem item : novosItens) {
            produtosIds.add(item.Product2Id);
            pedidosIds.add(item.OrderId);

        }

        // 2. Busca dados de apoio (Hierarquias e Pedidos com Endereço/CD)
        Map<Id, Product2> mapaProdutos = new Map<Id, Product2>([
            SELECT Id, Hierarquia_Produto__c FROM Product2 WHERE Id IN :produtosIds
        ]);

        for(Product2 p : mapaProdutos.values()) {
            if(p.Hierarquia_Produto__c != null) {
                hierarquiasIds.add(p.Hierarquia_Produto__c);
            }
        }
        
        Map<Id, Order> mapaPedidos = new Map<Id, Order>([
            SELECT Id, Centro_Distribuicao__c,
                   Endereco__r.Cidade__c, 
                   Endereco__r.Cidade__r.Estado__c, 
                   Endereco__r.Cidade__r.Estado__r.Pais__c 
            FROM Order WHERE Id IN :pedidosIds
        ]);

        // 3. SELECIONA AS REGRAS (Filtra pelo CD do pedido)
        // Aqui usamos o filtro de CD que você queria
        Set<Id> cdsIds = new Set<Id>();
        for(Order o : mapaPedidos.values()) if(o.Centro_Distribuicao__c != null) cdsIds.add(o.Centro_Distribuicao__c);

        Set<Id> locaisIds = new Set<Id>();
        for(Order o : mapaPedidos.values()) {
            if(o.Endereco__r != null) {
                if(o.Endereco__r.Cidade__c != null) locaisIds.add(o.Endereco__r.Cidade__c);
                if(o.Endereco__r.Cidade__r.Estado__c != null) locaisIds.add(o.Endereco__r.Cidade__r.Estado__c);
                if(o.Endereco__r.Cidade__r.Estado__r.Pais__c != null) locaisIds.add(o.Endereco__r.Cidade__r.Estado__r.Pais__c);
            }
        }

        Map<String, Frete__c> mapaRegras = FreteSelector.getMapaRegras(produtosIds, hierarquiasIds, locaisIds, cdsIds);
        System.debug(mapaRegras.values() + ' | ' + 'regras selecionadas');

        // 4. INSTANCIA O MOTOR
        MotorFrete motorF = new MotorFrete(mapaRegras);

        // 5. O LOOP FINAL
        for (OrderItem item : novosItens) {
            Order ped = mapaPedidos.get(item.OrderId);
            Id hId = mapaProdutos.get(item.Product2Id)?.Hierarquia_Produto__c;

            // Criamos o contexto do item atual
            ContextoFrete ctx = new ContextoFrete(item, ped, hId);

            System.debug(ctx + ' | ' + 'ctx criado');

            // O Motor resolve a hierarquia (Cidade > Estado > Pais) sozinho!
            Frete__c resultado = motorF.buscar(ctx);

            System.debug(resultado + ' | ' + 'resultado do motor');


            if (resultado != null) {
                item.Valor_Frete__c = resultado.Valor__c;
                System.debug(resultado );
            } else {
                System.debug('Nenhum frete encontrado para o item: ' + item.Id);
                item.addError('Erro: Margem não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');   

            }
        }
    }

    public static void resgatarValorImposto(List<OrderItem> novosItens){
        // 1. Coleta de IDs (Bulkify)
        Set<Id> produtosIds = new Set<Id>();
        Set<Id> pedidosIds = new Set<Id>();
        for (OrderItem item : novosItens) {
            produtosIds.add(item.Product2Id);
            pedidosIds.add(item.OrderId);

        }
        
        
        Map<Id, Order> mapaPedidos = new Map<Id, Order>([
            SELECT Id, Centro_Distribuicao__c, Endereco__r.Cidade__r.Estado__c
            FROM Order WHERE Id IN :pedidosIds
        ]);

        // 3. SELECIONA AS REGRAS (Filtra pelo CD do pedido)
        // Aqui usamos o filtro de CD que você queria
        Set<Id> cdsIds = new Set<Id>();
        for(Order o : mapaPedidos.values()) if(o.Centro_Distribuicao__c != null) cdsIds.add(o.Centro_Distribuicao__c);

        Set<Id> locaisIds = new Set<Id>();
        for(Order o : mapaPedidos.values()) {
            if(o.Endereco__r != null) {
                if(o.Endereco__r.Cidade__r.Estado__c != null) locaisIds.add(o.Endereco__r.Cidade__r.Estado__c);
            }
        }

        Map<String, Imposto__c> mapaRegras = ImpostoSelector.getMapaRegras(produtosIds, locaisIds, cdsIds);
        System.debug(mapaRegras.values() + ' | ' + 'regras selecionadas');

        // 4. INSTANCIA O MOTOR
        MotorImposto motorI = new MotorImposto(mapaRegras);

        // 5. O LOOP FINAL
        for (OrderItem item : novosItens) {
            Order ped = mapaPedidos.get(item.OrderId);
            // Criamos o contexto do item atual
            ContextoImposto ctx = new ContextoImposto(item, ped);
            
            
            Imposto__c resultado = motorI.buscar(ctx);
            System.debug(ctx + ' | ' + 'ctx criado');


            System.debug(resultado + ' | ' + 'resultado do motor');


            if (resultado != null) {
                item.Porcentagem_Imposto__c = resultado.Imposto_Custo__c;
                System.debug(resultado );
            } else {
                System.debug('Nenhum imposto encontrado para o item: ' + item.Id);
                item.addError('Erro: Imposto não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');   

            }
        }

    }

    public static void resgatarMargem(List<OrderItem> novosItens){
        // 1. Coleta de IDs (Bulkify)
        Set<Id> produtosIds = new Set<Id>();
        Set<Id> pedidosIds = new Set<Id>();
        for (OrderItem item : novosItens) {
            produtosIds.add(item.Product2Id);
            pedidosIds.add(item.OrderId);
        }
        
        // 2. Query do Pedido com TODOS os campos necessários para o Contexto e para o Selector
        Map<Id, Order> mapaPedidos = new Map<Id, Order>([
            SELECT Id, AccountId, Account.Grupo_Clientes__c, Centro_Distribuicao__c, 
                Endereco__r.Cidade__c, 
                Endereco__r.Cidade__r.Estado__c,
                Endereco__r.Cidade__r.Estado__r.Pais__c
            FROM Order WHERE Id IN :pedidosIds
        ]);

        // 3. SELECIONA AS REGRAS (Prepara os Sets para o Selector)
        Set<Id> cdsIds = new Set<Id>();
        Set<Id> locaisIds = new Set<Id>();
        Set<Id> contasIds = new Set<Id>();
        Set<Id> gruposContasIds = new Set<Id>();

        for(Order o : mapaPedidos.values()) {
            // IDs de Negócio
            contasIds.add(o.AccountId);
            if(o.Account.Grupo_Clientes__c != null) gruposContasIds.add(o.Account.Grupo_Clientes__c);
            if(o.Centro_Distribuicao__c != null) cdsIds.add(o.Centro_Distribuicao__c);

            // IDs Geográficos
            if(o.Endereco__r != null) {
                if(o.Endereco__r.Cidade__c != null) locaisIds.add(o.Endereco__r.Cidade__c);
                if(o.Endereco__r.Cidade__r?.Estado__c != null) locaisIds.add(o.Endereco__r.Cidade__r.Estado__c);
                if(o.Endereco__r.Cidade__r?.Estado__r?.Pais__c != null) locaisIds.add(o.Endereco__r.Cidade__r.Estado__r.Pais__c);
            }
        }

        // Agora a chamada possui todos os parâmetros necessários
        Map<String, Margem__c> mapaRegras = margemSelector.getMapaRegras(produtosIds, locaisIds, cdsIds, contasIds, gruposContasIds);
        System.debug(mapaRegras.size() + ' regras carregadas no mapa.');

        // 4. INSTANCIA O MOTOR
        MotorMargem motorM = new MotorMargem(mapaRegras);

        // 5. O LOOP FINAL
        for (OrderItem item : novosItens) {
            Order ped = mapaPedidos.get(item.OrderId);
            
            // Criamos o contexto do item atual (Certifique-se que o construtor aceita esses campos)
            ContextoMargem ctx = new ContextoMargem(item, ped);
            
            Margem__c resultado = motorM.buscar(ctx);

            if (resultado != null) {
                item.Porcentagem_Margem__c = resultado.Valor__c;
            } else {
                item.addError('Erro: Margem não existe. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing.');   

                System.debug('Nenhuma Margem encontrada para o item: ' + item.Product2Id);
            }
        }
    }

}