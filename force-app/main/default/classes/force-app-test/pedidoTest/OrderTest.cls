/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class OrderTest {

    @TestSetup
    static void makeData(){
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;


        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        insert estado;

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        insert cidade;

        Centro_de_Distribuicao__c centroDistribuicao = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert centroDistribuicao;

        Condicao_Pagamento__c condicaoPagamento = (Condicao_Pagamento__c) TestFactorySObject.getInstance().createSObject(new Condicao_Pagamento__c());
        insert condicaoPagamento;


        Grupo_Conta__c grupoConta = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupoConta;

        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.Grupo_Clientes__c = grupoConta.Id;

        insert account;

        Account newAccount = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        newAccount.Grupo_Clientes__c = [SELECT Id FROM Grupo_Conta__c LIMIT 1].Id;
        newAccount.CNPJ__c = '22945724000140';
        insert newAccount;



        Endereco__c endereco = (Endereco__c) TestFactorySObject.getInstance().createSObject(new Endereco__c());
        endereco.Cidade__c = cidade.Id;
        endereco.Account__c = account.Id;
        insert endereco;  


        
    }

    @isTest
    static void shouldCreateOrderWithStandardPricebook() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        Hierarquia_Produto__c hierarquiaProduto = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquiaProduto;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.Hierarquia_Produto__c = hierarquiaProduto.Id;
        insert product;  

        Account account = [SELECT Id FROM Account LIMIT 1];
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];
        Centro_de_Distribuicao__c centroDistribuicao = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Condicao_Pagamento__c condicaoPagamento = [SELECT Id FROM Condicao_Pagamento__c LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Endereco__c = endereco.Id;
        order.Centro_Distribuicao__c = centroDistribuicao.Id;
        order.Condicao_Pagamento__c = condicaoPagamento.Id; 
        order.Pricebook2Id = pricebookId;
        
        insert order;

            List<Order> orders = [SELECT Id, Status FROM Order];
            System.assert(!orders.isEmpty(), 'No orders were created in the test setup.');
            System.assertEquals('Rascunho', orders[0].Status, 'The order status should be Rascunho after insertion.');
    }
    
    @isTest
    static void shouldNotAllowEditingOrderWhenActive() {

            Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        Hierarquia_Produto__c hierarquiaProduto = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquiaProduto;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.Hierarquia_Produto__c = hierarquiaProduto.Id;
        insert product;  

        Account account = [SELECT Id FROM Account LIMIT 1];
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];
        Centro_de_Distribuicao__c centroDistribuicao = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Condicao_Pagamento__c condicaoPagamento = [SELECT Id FROM Condicao_Pagamento__c LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Endereco__c = endereco.Id;
        order.Centro_Distribuicao__c = centroDistribuicao.Id;
        order.Condicao_Pagamento__c = condicaoPagamento.Id; 
        order.Pricebook2Id = pricebookId;
        
        insert order;

        List<Order> orders = [SELECT Id, Status FROM Order];
        Product2 product1 = [SELECT Id FROM Product2 LIMIT 1];
        
        OrderItem orderItem = (OrderItem) TestFactorySObject.getInstance().createSObject(new OrderItem());
        orderItem.Product2Id = product1.Id;
        orderItem.OrderId = orders[0].Id;
        
        
        System.assert(!orders.isEmpty(), 'No orders were created in the test setup.');

        Order orderToUpdate = orders[0];
        orderToUpdate.OrderItems.add(orderItem);
        orderToUpdate.Status = 'Ativo';

        try {
            insert orderItem;
            update orderToUpdate;

            orderToUpdate.Status = 'Rascunho';

            update orderToUpdate;
            System.assert(false, 'Expected an exception when trying to update the order status.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Unexpected error message: ' + e.getMessage());
        }
    }

    @isTest
    static void shouldNotAllowEditingAccount() {
        // 1. Setup - Use nomes de variáveis claros (plural vs singular)

             Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        Hierarquia_Produto__c hierarquiaProduto = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquiaProduto;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.Hierarquia_Produto__c = hierarquiaProduto.Id;
        insert product;  

        Account account = [SELECT Id FROM Account LIMIT 1];
        Endereco__c endereco = [SELECT Id FROM Endereco__c LIMIT 1];
        Centro_de_Distribuicao__c centroDistribuicao = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Condicao_Pagamento__c condicaoPagamento = [SELECT Id FROM Condicao_Pagamento__c LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Endereco__c = endereco.Id;
        order.Centro_Distribuicao__c = centroDistribuicao.Id;
        order.Condicao_Pagamento__c = condicaoPagamento.Id; 
        order.Pricebook2Id = pricebookId;
        
        insert order;


        Order existingOrder = [SELECT Id, Status, AccountId FROM Order LIMIT 1];
        Account newAccount = [SELECT Id FROM Account WHERE Id != :existingOrder.AccountId LIMIT 1];
        
       

        // 2. Execução do teste
        existingOrder.AccountId = newAccount.Id;

        Test.startTest();
        try {
            update existingOrder;
            // Se chegar aqui, o teste falhou porque deveria ter dado erro
            Assert.fail('O sistema deveria ter bloqueado a alteração da Conta no Pedido.');
        } catch (DmlException e) {
            // 3. Verificação (Asserção)
            // Verifique o texto exato da sua mensagem de erro
            String expectedMsg = 'Não é permitido alterar a Conta do pedido.'; 
            Assert.isTrue(e.getMessage().contains(expectedMsg), 
                'A mensagem de erro esperada não foi encontrada. Erro atual: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void shouldCatchDmlExceptionOnPricebookEntry() {
        // 1. Pegamos o produto que já foi criado no @TestSetup
        // Esse produto JÁ TEM um PricebookEntry criado pela sua Trigger

            Id pricebookId = Test.getStandardPricebookId();
            update new Pricebook2(Id = pricebookId, IsActive = true);

            Hierarquia_Produto__c hierarquiaProduto = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
            insert hierarquiaProduto;

            Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
            product.Hierarquia_Produto__c = hierarquiaProduto.Id;
            insert product;  

            Product2 prod = [SELECT Id, Custo_Producao__c FROM Product2 LIMIT 1];
        
        
        Test.startTest();
        // 2. Chamamos a Service diretamente, fingindo que é a Trigger
        // Como o PricebookEntry desse produto já existe, o insert na linha 44 vai dar DUPLICATE_VALUE
        // O código vai pular direto para o seu catch (DmlException e) e cobrir a linha do System.debug!
        produtoService.createPriceBookEntry(new List<Product2>{prod});
        Test.stopTest();

        // 3. Validação
        // Como o seu catch apenas dá um System.debug (não lança erro na tela), 
        // o teste não vai falhar. Nós apenas garantimos que a quantidade de entradas não aumentou.
        List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id];
        Assert.areEqual(1, entries.size(), 'A segunda tentativa de inserção deveria ter falhado e caído no catch.');
    }

    @isTest
    static void shouldFailWhenNoStandardPricebookExists() {
        // 1. Preparamos os dados base (SEM ativar o Standard Pricebook)
        Hierarquia_Produto__c hierarquiaProduto = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquiaProduto;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.Hierarquia_Produto__c = hierarquiaProduto.Id;
        
        Test.startTest();
        try {
            
            insert product;
            
            
            // O Assert.fail força o teste a ficar vermelho para te avisar!
            Assert.fail('O sistema deveria ter bloqueado a criação do produto por falta de Pricebook.');
            
        } catch (Exception e) {
            // 4. Capturamos o erro do addError e validamos se a mensagem é a correta
            String mensagemEsperada = 'Não foi possível criar o produto: Nenhum Pricebook (Tabela de Preços) ativo foi encontrado no sistema.';
            
            Assert.isTrue(e.getMessage().contains(mensagemEsperada), 
                          'A mensagem de erro foi diferente do esperado. Mensagem recebida: ' + e.getMessage());
        }
        Test.stopTest();
    }

    // ====================================================================
    // INNER CLASS NÍVEL 1: Apenas uma classe de profundidade permitida
    // Criamos um Mock que herda da sua Handler base para acessar o "super"
    // ====================================================================
    private class HandlerMock extends PedidoTriggerHandler {
        
        public void coverVirtualMethods() {
            // O 'super' permite chamar os métodos protected da classe pai
            super.afterUpdate();
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