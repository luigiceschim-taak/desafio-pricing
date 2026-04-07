public with sharing class MotorBusca {
    public MotorBusca() {

    }


    
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
                System.debug('Nenhuma Margem encontrada para o item: ' + item.Product2Id);
            }
        }
    }

    // public static void resgatarImpostoParaItem(List<OrderItem> novosItens){
        
    //     Set<Id> produtosIds = new Set<Id>();
    //     Set<Id> pedidosId = new Set<Id>();
        
    //     for (OrderItem item : novosItens) {
    //         if (item.Product2Id != null) {
    //             produtosIds.add(item.Product2Id);
    //             pedidosId.add(item.OrderId);
    //         }
    //     }
    //     if (produtosIds.isEmpty()) return;

    //     Map<Id, Order> mapaPedidos = new Map<Id, Order>([
    //     SELECT Id, Centro_Distribuicao__c FROM Order WHERE Id IN :pedidosId
    //     ]);

    //     // Coletamos os IDs dos CDs envolvidos para filtrar a query de impostos
    //     Set<Id> cdsIds = new Set<Id>();
    //     for (Order ord : mapaPedidos.values()) {
    //         if (ord.Centro_Distribuicao__c != null) {
    //             cdsIds.add(ord.Centro_Distribuicao__c);
    //         }
    //     }


    //     Map<String, Imposto__c> mapaImpostos = new Map<String, Imposto__c>();

    //     for(Imposto__c impo : [
    //         SELECT Id, Imposto_Custo__c, Product__c, Centro_Distribuicao__c 
    //         FROM Imposto__c 
    //         WHERE Product__c IN :produtosIds 
    //         AND Status__c = 'Aprovado' 
    //         AND Centro_Distribuicao__c IN :cdsIds
    //         ]){

    //         String chave = (String)impo.Product__c + (String)impo.Centro_Distribuicao__c;
    //         mapaImpostos.put(chave, impo);
    //     }

    //     for (OrderItem item : novosItens) {
    //     Order pedidoPai = mapaPedidos.get(item.OrderId);
        
    //         if (pedidoPai != null && pedidoPai.Centro_Distribuicao__c != null) {
    //             String chaveBusca = (String)item.Product2Id + (String)pedidoPai.Centro_Distribuicao__c;
                
    //             if (mapaImpostos.containsKey(chaveBusca)) {
    //                 item.Porcentagem_Imposto__c = mapaImpostos.get(chaveBusca).Imposto_Custo__c;
    //                 System.debug('Imposto encontrado :' + mapaImpostos.get(chaveBusca).Imposto_Custo__c);
    //             } else {
    //                 // Caso não encontre, você pode definir um valor padrão ou logar um aviso
    //                 System.debug('Aviso: Nenhum imposto encontrado para o Produto ' + item.Product2Id + ' no CD ' + pedidoPai.Centro_Distribuicao__c);
    //                 item.addError('Erro: não há imposto para este produto. Não está autorizada a venda deste produto devido à falta de parâmetros. Contate o time de Pricing. ');
    //             }
    //         }
    //     }
    // }

    // public static  void resgatarValorFreteParaItem(List<OrderItem> novosItens){
    //     System.debug('iniciando');

    //     Set<Id> produtosIds = new Set<Id>();
    //     Set<Id> pedidosIds = new Set<Id>();
    //     Set<Id> hierarquiasIds = new Set<Id>();
       
    
    //     for (OrderItem item : novosItens) {
    //         if (item.Product2Id != null) {
    //             produtosIds.add(item.Product2Id);
    //             pedidosIds.add(item.OrderId);
    //             System.debug(item.Product2Id);
    //             System.debug(item.OrderId);
    //         }
    //     }

    //     Map<Id, Product2> mapaProdutosParaHierarquia = new Map<Id, Product2>([
    //         SELECT Id, Hierarquia_Produto__c FROM Product2 WHERE Id IN :produtosIds
    //     ]);

        
    //     for (Product2 p : mapaProdutosParaHierarquia.values()) {
    //         if (p.Hierarquia_Produto__c != null) {
    //             System.debug('hierarquia: ' + p.Hierarquia_Produto__c);
    //             hierarquiasIds.add(p.Hierarquia_Produto__c);
    //         }
    //     }


    //     if (produtosIds.isEmpty()) return;

    //     // 1. Buscamos o Pedido "subindo" a escada da Cidade para pegar Estado e Pais
    //     Map<Id, Order> mapaPedidos = new Map<Id, Order>([
    //         SELECT Id, 
    //         Endereco__r.Cidade__c, 
    //         Endereco__r.Cidade__r.Estado__c, 
    //         Endereco__r.Cidade__r.Estado__r.Pais__c 
    //         FROM Order 
    //         WHERE Id IN :pedidosIds
    //         ]);

    //     // 2. Criamos o Mapa de Regras com Chave Composta (Alvo + Localidade)
    //     Map<String, Frete__c> mapaRegras = new Map<String, Frete__c>();
        
    //     // Buscamos fretes que sejam de Produtos OU de Hierarquias
    //     for (Frete__c f : [
    //         SELECT Valor__c, Produto__c, Hierarquia_Produto__c, Cidade__c, Estado__c, Pais__c 
    //         FROM Frete__c 
    //         WHERE Status__c = 'Aprovado'
    //         AND (Produto__c IN :produtosIds OR Hierarquia_Produto__c IN :hierarquiasIds)
    //     ]) {
    //         // Define o ID do "Alvo" (Produto ou Hierarquia)
    //         Id alvoId = (f.Produto__c != null) ? f.Produto__c : f.Hierarquia_Produto__c;
            
    //         // Define a localidade da regra (ID da Cidade, Estado ou Pais)
    //         Id locId = (f.Cidade__c != null) ? f.Cidade__c : 
    //                 (f.Estado__c != null) ? f.Estado__c : f.Pais__c;

    //         if (alvoId != null && locId != null) {
    //             mapaRegras.put((String)alvoId + (String)locId, f);
    //         }
    //     }

    //     System.debug(mapaRegras.values());

    //     // 3. O "Motor" de Busca em Cascata
    //     for (OrderItem item : novosItens) {
    //         Order ped = mapaPedidos.get(item.OrderId);
    //         if (ped == null || ped.Endereco__r.Cidade__c == null) {
    //             item.addError('Erro: Pedido sem endereço de entrega definido.');
    //             continue;
    //         }
    //         Product2 prodDados = mapaProdutosParaHierarquia.get(item.Product2Id);
    //                 // Dentro do seu loop de OrderItem...
    //         Id pId = item.Product2Id;
    //         Id hId = (prodDados != null) ? prodDados.Hierarquia_Produto__c : null;
    //         Id cidId = ped.Endereco__r.Cidade__c;
    //         Id estId = ped.Endereco__r.Cidade__r.Estado__c;
    //         Id paiId = ped.Endereco__r.Cidade__r.Estado__r.Pais__c;

    //         Frete__c melhorMatch = null;
    //         Integer maiorScore = -1;

    //         // Mapa de possibilidades para o item atual
    //         Map<String, Integer> possibilidades = new Map<String, Integer>();

    //         // BLOCO PRODUTO: Base 1000 (Sempre vence a hierarquia)
    //         if (pId != null) {
    //             if (cidId != null) possibilidades.put((String)pId + cidId, 1500); // Cidade
    //             if (estId != null) possibilidades.put((String)pId + estId, 1100); // Estado
    //             if (paiId != null) possibilidades.put((String)pId + paiId, 1010); // País
    //         }

    //         // BLOCO HIERARQUIA: Base 100
    //         if (hId != null) {
    //             if (cidId != null) possibilidades.put((String)hId + cidId, 600); // Cidade
    //             if (estId != null) possibilidades.put((String)hId + estId, 200); // Estado
    //             if (paiId != null) possibilidades.put((String)hId + paiId, 110); // País
    //         }

    //         system.debug(possibilidades);

    //         // MOTOR DE BUSCA
    //         for (String chave : possibilidades.keySet()) {
    //             if (mapaRegras.containsKey(chave)) {
    //                 Integer scoreDaChave = possibilidades.get(chave);
                    
    //                 // Se encontrarmos um frete com score maior, ele se torna o favorito
    //                 if (scoreDaChave > maiorScore) {
    //                     maiorScore = scoreDaChave;
    //                     melhorMatch = mapaRegras.get(chave);
    //                 }
    //             }
    //         }

    //         if (melhorMatch != null) {
    //             item.Valor_Frete__c = melhorMatch.Valor__c;
    //         } else {
    //             item.addError('ERRO: Nenhum frete encontrado para este Produto ou Hierarquia.');
    //         }
        
    //     }
    // }

    public static  void resgatarMargemParaItem(List<OrderItem> novosItens) {
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
}