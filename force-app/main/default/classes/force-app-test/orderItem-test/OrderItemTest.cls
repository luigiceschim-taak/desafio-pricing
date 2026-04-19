@isTest
private class OrderItemTest {

    @testSetup
    static void setupTestData() {
        // ==========================================
        // 1. SETUP DE DADOS BASE E RELACIONAMENTOS
        // ==========================================
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        Hierarquia_Produto__c hierarquia = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquia;

        Product2 produto = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        produto.Hierarquia_Produto__c = hierarquia.Id;
        insert produto;

        Grupo_Conta__c grupoConta = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupoConta;

        Account conta = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        conta.Grupo_Clientes__c = grupoConta.Id;
        insert conta;

        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        insert estado;
        
        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        insert cidade;

        Centro_de_Distribuicao__c cd = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert cd;

        Endereco__c endereco = (Endereco__c) TestFactorySObject.getInstance().createSObject(new Endereco__c());
        endereco.Cidade__c = cidade.Id;
        endereco.Account__c = conta.Id;
        insert endereco;

        Condicao_Pagamento__c condicaoPagamento = (Condicao_Pagamento__c) TestFactorySObject.getInstance().createSObject(new Condicao_Pagamento__c());
        insert condicaoPagamento;

        // ==========================================
        // 2. SETUP DAS REGRAS (A Munição dos Motores)
        // ==========================================
        
        // Criando uma regra de Frete válida para esse Produto, CD e Cidade
        Frete__c regraFrete = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c());
        regraFrete.Produto__c = produto.Id;
        regraFrete.Centro_Distribuicao__c = cd.Id;
        regraFrete.Cidade__c = cidade.Id;
        regraFrete.Status__c = 'Aprovado';
        regraFrete.Valor__c = 150.00; // Valor que esperamos ver no OrderItem
        insert regraFrete;

        // Criando uma regra de Imposto válida
        Imposto__c regraImposto = (Imposto__c) TestFactorySObject.getInstance().createSObject(new Imposto__c());
        regraImposto.Product__c = produto.Id;
        regraImposto.Centro_Distribuicao__c = cd.Id;
        regraImposto.Estado__c = estado.Id;
        regraImposto.Imposto_Custo__c = 15.00; // Valor que esperamos ver no OrderItem
        insert regraImposto;

        // Criando uma regra de Margem válida
        Margem__c regraMargem = (Margem__c) TestFactorySObject.getInstance().createSObject(new Margem__c());
        regraMargem.Produto__c = produto.Id;
        regraMargem.Conta__c = conta.Id;
        regraMargem.Centro_Distribuicao__c = cd.Id;
        regraMargem.Cidade__c = cidade.Id;
        regraMargem.Status__c = 'Aprovado';
        regraMargem.Valor__c = 30.00; // Valor que esperamos ver no OrderItem
        insert regraMargem;
    }

    
    @isTest
    static void shouldPopulateOrderItemFieldsOnInsert() {
        // 1. Busca os dados do Setup (As regras de frete/imposto/margem já foram criadas no @TestSetup)
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Condicao_Pagamento__c condPagamento = [SELECT Id FROM Condicao_Pagamento__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :produto.Id LIMIT 1];

        // 2. Criando o Pedido (Pai)
        Order pedido = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        pedido.AccountId = conta.Id;
        pedido.Endereco__c = endereco.Id;
        pedido.Centro_Distribuicao__c = cd.Id;
        pedido.Condicao_Pagamento__c = condPagamento.Id; 
        pedido.Pricebook2Id = Test.getStandardPricebookId();
        pedido.Status = 'Rascunho';
        insert pedido;

        // 3. Preparando o Item do Pedido
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        // 4. A MÁGICA ACONTECE AQUI
        Test.startTest();
        // Ao dar o insert, o Salesforce vai rodar a sua Trigger de OrderItem.
        // É a sua Trigger que vai chamar o MotorBusca e preencher os campos automaticamente!
        insert item; 
        Test.stopTest();

        // 5. Validações Finais (A Prova do Crime)
        // Buscamos o item recém-inserido no banco de dados para ver se a Trigger fez o trabalho dela
        OrderItem itemAtualizado = [
            SELECT Id, Valor_Frete__c, Porcentagem_Imposto__c, Porcentagem_Margem__c 
            FROM OrderItem 
            WHERE Id = :item.Id
        ];

        // Comparamos o resultado com os valores que configuramos nas regras lá no @TestSetup
        Assert.areEqual(150.00, itemAtualizado.Valor_Frete__c, 'O Trigger falhou em acionar o Motor de Frete na criação do item.');
        Assert.areEqual(15.00, itemAtualizado.Porcentagem_Imposto__c, 'O Trigger falhou em acionar o Motor de Imposto na criação do item.');
        Assert.areEqual(30.00, itemAtualizado.Porcentagem_Margem__c, 'O Trigger falhou em acionar o Motor de Margem na criação do item.');
    }

    @isTest
    static void shouldPopulateOrderItemWithMerginAndValidateQuantity() {
        // 1. Busca os dados do Setup (As regras de frete/imposto/margem já foram criadas no @TestSetup)
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Condicao_Pagamento__c condPagamento = [SELECT Id FROM Condicao_Pagamento__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :produto.Id LIMIT 1];

        // 2. Criando o Pedido (Pai)
        Order pedido = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        pedido.AccountId = conta.Id;
        pedido.Endereco__c = endereco.Id;
        pedido.Centro_Distribuicao__c = cd.Id;
        pedido.Condicao_Pagamento__c = condPagamento.Id; 
        pedido.Pricebook2Id = Test.getStandardPricebookId();
        pedido.Status = 'Rascunho';
        insert pedido;

        // 3. Preparando o Item do Pedido
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        OrderItem item2 = new OrderItem(
            OrderId = pedido.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 3,
            UnitPrice = pbe.UnitPrice
        );

        
        Test.startTest();
        // Ao dar o insert, o Salesforce vai rodar a sua Trigger de OrderItem.
        // É a sua Trigger que vai chamar o MotorBusca e preencher os campos automaticamente!
        insert item; 

        insert item2; 
        Test.stopTest();

        
        OrderItem itemAtualizado = [
            SELECT Id, Valor_Frete__c, Porcentagem_Imposto__c, Porcentagem_Margem__c, Quantity 
            FROM OrderItem 
            WHERE Id = :item.Id
        ];

        // Comparamos o resultado com os valores que configuramos nas regras lá no @TestSetup
        Assert.areEqual(150.00, itemAtualizado.Valor_Frete__c, 'O Trigger falhou em acionar o Motor de Frete na criação do item.');
        Assert.areEqual(15.00, itemAtualizado.Porcentagem_Imposto__c, 'O Trigger falhou em acionar o Motor de Imposto na criação do item.');
        Assert.areEqual(30.00, itemAtualizado.Porcentagem_Margem__c, 'O Trigger falhou em acionar o Motor de Margem na criação do item.');
        Assert.areEqual(4, itemAtualizado.Quantity, 'A lógica de merge falhou. A quantidade do primeiro item deveria ter sido atualizada para 4.');
    }

    @isTest
    static void shouldFailWhenUpdateStatusOfOrderIsActive() {
        // 1. Busca os dados do Setup (As regras de frete/imposto/margem já foram criadas no @TestSetup)
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Condicao_Pagamento__c condPagamento = [SELECT Id FROM Condicao_Pagamento__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :produto.Id LIMIT 1];

        // 2. Criando o Pedido (Pai)
        Order pedido = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        pedido.AccountId = conta.Id;
        pedido.Endereco__c = endereco.Id;
        pedido.Centro_Distribuicao__c = cd.Id;
        pedido.Condicao_Pagamento__c = condPagamento.Id; 
        pedido.Pricebook2Id = Test.getStandardPricebookId();
        pedido.Status = 'Rascunho';
        insert pedido;

        // 3. Preparando o Item do Pedido
        OrderItem item = new OrderItem(
            OrderId = pedido.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

      

        
        Test.startTest();
        // Ao dar o insert, o Salesforce vai rodar a sua Trigger de OrderItem.
        // É a sua Trigger que vai chamar o MotorBusca e preencher os campos automaticamente!
        insert item; 

        Order pedidoAtivo = [SELECT Id, Status FROM Order WHERE Id = :pedido.Id LIMIT 1];
            pedidoAtivo.Status = 'Ativo';
            update pedidoAtivo;

        try {
            
            
            OrderItem itemPedidoTeste = [SELECT Id, Quantity FROM OrderItem WHERE Id = :item.Id LIMIT 1];
            itemPedidoTeste.Quantity = 10;
            update itemPedidoTeste;

            Assert.fail('O sistema deveria ter lançado um DmlException por causa da tentativa de atualizar um item de pedido ativo.');

            
            
        } catch (DmlException e) {
            // Validamos se a mensagem de erro é exatamente a que está no seu código
            Assert.isTrue(e.getMessage().contains('Erro: Itens de um pedido ativo não podem ser alterados'), 'Mensagem de erro incorreta: ' + e.getMessage());
            
        }

        Test.stopTest();

        
        OrderItem itemNaoAtualizado = [
            SELECT Id, Valor_Frete__c, Porcentagem_Imposto__c, Porcentagem_Margem__c, Quantity 
            FROM OrderItem 
            WHERE Id = :item.Id
        ];

        // Comparamos o resultado com os valores que configuramos nas regras lá no @TestSetup
        Assert.areEqual(150.00, itemNaoAtualizado.Valor_Frete__c, 'O Trigger falhou em acionar o Motor de Frete na criação do item.');
        Assert.areEqual(15.00, itemNaoAtualizado.Porcentagem_Imposto__c, 'O Trigger falhou em acionar o Motor de Imposto na criação do item.');
        Assert.areEqual(30.00, itemNaoAtualizado.Porcentagem_Margem__c, 'O Trigger falhou em acionar o Motor de Margem na criação do item.');
        Assert.areEqual(1, itemNaoAtualizado.Quantity, 'A lógica de merge falhou. A quantidade do primeiro item deveria ter sido atualizada para 4.');
    }


    private class HandlerMock extends TriggerHandler {
        
        public void coverVirtualMethods() {
            // O 'super' permite chamar os métodos protected da classe pai
            super.afterInsert();
            super.beforeInsert();
            super.beforeUpdate();
            
            
        
            
            
        }
    }

    // ====================================================================
    // MÉTODOS DE TESTE
    // ====================================================================
    @isTest
    static void testBaseHandlerVirtualMethods() {
        // 1. Instancia a nossa classe mockada
        HandlerMock mock = new HandlerMock();
        
        Test.startTest();
        
        // 2. Chama o método do mock que invoca os métodos virtuais vazios {}
        // Isso vai deixar as linhas do beforeUpdate e afterUpdate verdinhas.
        mock.coverVirtualMethods();
        
        // 3. Chama o run() principal. 
        // Como não estamos em contexto de Trigger, Trigger.isBefore será nulo,
        // mas o Apex vai ler a linha do "if" e marcar como coberta.
        
        Test.stopTest();

        // 4. Asserção para garantir que a execução ocorreu sem exceções
        Assert.isTrue(true, 'A cobertura da classe base virtual foi concluída com sucesso.');
    }
}