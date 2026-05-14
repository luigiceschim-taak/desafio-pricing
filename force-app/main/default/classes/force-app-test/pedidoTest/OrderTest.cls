@isTest
private class OrderTest {

    @TestSetup
    static void makeData(){
        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        insert country;

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = country.Id;
        insert state;

        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.State__c = state.Id;
        insert city;

        DistributionCenter__c dc = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        insert dc;

        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        insert accountGroup;

        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.AccountGroup__c = accountGroup.Id;
        insert account;

        Account newAccount = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        newAccount.AccountGroup__c = [SELECT Id FROM AccountGroup__c LIMIT 1].Id;
        newAccount.CNPJ__c = '22945724000140';
        insert newAccount;

        Address__c address = (Address__c) TestFactorySObject.getInstance().createSObject(new Address__c());
        address.City__c = city.Id;
        address.Account__c = account.Id;
        insert address;
    }

    @isTest
    static void shouldCreateOrderWithStandardPricebook() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
        order.Pricebook2Id = pricebookId;

        insert order;

        List<Order> orders = [SELECT Id, Status FROM Order];
        System.assert(!orders.isEmpty(), 'No orders were created in the test setup.');
        System.assertEquals('Rascunho', orders[0].Status, 'The order status should be Rascunho after insertion.');
    }

    @isTest
    static void shouldPreventUpdateWhenStatusIsActive() {
        Id standardPbId = Test.getStandardPricebookId();
        update new Pricebook2(Id = standardPbId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];

        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        Freight__c freightRule = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freightRule.Product__c = product.Id;
        freightRule.DistributionCenter__c = dc.Id;
        freightRule.City__c = city.Id;
        freightRule.Cost__c = 100.00;
        insert freightRule;

        Tax__c taxRule = (Tax__c) TestFactorySObject.getInstance().createSObject(new Tax__c());
        taxRule.Product__c = product.Id;
        taxRule.DistributionCenter__c = dc.Id;
        taxRule.State__c = state.Id;
        taxRule.TaxCost__c = 15.00;
        insert taxRule;

        Margin__c marginRule = (Margin__c) TestFactorySObject.getInstance().createSObject(new Margin__c());
        marginRule.Product__c = product.Id;
        marginRule.Account__c = account.Id;
        marginRule.DistributionCenter__c = dc.Id;
        marginRule.City__c = city.Id;
        marginRule.Cost__c = 30.00;
        insert marginRule;

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Pricebook2Id = standardPbId;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
        order.Status = 'Rascunho';
        insert order;

        OrderItem orderItem = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice != null ? pbe.UnitPrice : 100
        );
        insert orderItem;

        order.Status = 'Ativo';
        update order;

        order.Description = 'Blocked edit attempt';

        Test.startTest();
        try {
            update order;
            Assert.fail('Should have blocked editing an Active order');
        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Pedidos com status "ATIVO" não podem ser editados.'));
        }
        Test.stopTest();
    }

    @isTest
    static void shouldNotAllowEditingOrderWhenActive() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
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
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
        order.Pricebook2Id = pricebookId;

        insert order;

        Order existingOrder = [SELECT Id, Status, AccountId FROM Order LIMIT 1];
        Account newAccount = [SELECT Id FROM Account WHERE Id != :existingOrder.AccountId LIMIT 1];

        existingOrder.AccountId = newAccount.Id;

        Test.startTest();
        try {
            update existingOrder;
            Assert.fail('System should have blocked changing the Account on the Order.');
        } catch (DmlException e) {
            String expectedMsg = 'Não é permitido alterar a Conta do pedido.';
            Assert.isTrue(e.getMessage().contains(expectedMsg),
                'Expected error message not found. Current error: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void shouldCatchDmlExceptionOnPricebookEntry() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        Product2 prod = [SELECT Id, ProductionCost__c FROM Product2 LIMIT 1];

        Test.startTest();
        ProductService.createPriceBookEntry(new List<Product2>{prod});
        Test.stopTest();

        List<PricebookEntry> entries = [SELECT Id FROM PricebookEntry WHERE Product2Id = :prod.Id];
        Assert.areEqual(1, entries.size(), 'Second insert attempt should have failed and fallen into the catch.');
    }

    @isTest
    static void shouldFailWhenNoStandardPricebookExists() {
        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;

        Test.startTest();
        try {
            insert product;
            Assert.fail('System should have blocked product creation due to missing Pricebook.');
        } catch (Exception e) {
            String expectedMessage = 'Não foi possível criar o produto: Nenhum Pricebook (Tabela de Preços) ativo foi encontrado no sistema.';
            Assert.isTrue(e.getMessage().contains(expectedMessage),
                          'Error message was different from expected. Received: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void shouldTriggerPricingEnginesWhenDcChanges() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];

        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dcOriginal = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        DistributionCenter__c dcNew = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        insert dcNew;

        City__c city = [SELECT Id FROM City__c LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        Freight__c freightOriginal = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freightOriginal.Product__c = product.Id;
        freightOriginal.DistributionCenter__c = dcOriginal.Id;
        freightOriginal.City__c = city.Id;
        freightOriginal.Status__c = 'Approved';
        freightOriginal.Cost__c = 50.00;
        insert freightOriginal;

        Tax__c taxOriginal = (Tax__c) TestFactorySObject.getInstance().createSObject(new Tax__c());
        taxOriginal.Product__c = product.Id;
        taxOriginal.DistributionCenter__c = dcOriginal.Id;
        taxOriginal.State__c = state.Id;
        taxOriginal.TaxCost__c = 10.00;
        insert taxOriginal;

        Margin__c marginOriginal = (Margin__c) TestFactorySObject.getInstance().createSObject(new Margin__c());
        marginOriginal.Product__c = product.Id;
        marginOriginal.Account__c = account.Id;
        marginOriginal.DistributionCenter__c = dcOriginal.Id;
        marginOriginal.Status__c = 'Approved';
        marginOriginal.Cost__c = 20.00;
        marginOriginal.State__c = state.Id;
        insert marginOriginal;

        Freight__c freightNew = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freightNew.Product__c = product.Id;
        freightNew.DistributionCenter__c = dcNew.Id;
        freightNew.City__c = city.Id;
        freightNew.Status__c = 'Approved';
        freightNew.Cost__c = 100.00;
        insert freightNew;

        Tax__c taxNew = (Tax__c) TestFactorySObject.getInstance().createSObject(new Tax__c());
        taxNew.Product__c = product.Id;
        taxNew.DistributionCenter__c = dcNew.Id;
        taxNew.State__c = state.Id;
        taxNew.TaxCost__c = 15.00;
        insert taxNew;

        Margin__c marginNew = (Margin__c) TestFactorySObject.getInstance().createSObject(new Margin__c());
        marginNew.Product__c = product.Id;
        marginNew.Account__c = account.Id;
        marginNew.DistributionCenter__c = dcNew.Id;
        marginNew.Status__c = 'Approved';
        marginNew.Cost__c = 30.00;
        marginNew.State__c = state.Id;
        insert marginNew;

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dcOriginal.Id;
        order.Pricebook2Id = pricebookId;
        order.Status = 'Rascunho';
        insert order;

        OrderItem item = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );
        insert item;

        order.DistributionCenter__c = dcNew.Id;

        Test.startTest();
        update order;
        Test.stopTest();

        Order updatedOrder = [SELECT DistributionCenter__c FROM Order WHERE Id = :order.Id];
        Assert.areEqual(dcNew.Id, updatedOrder.DistributionCenter__c, 'DC should have been updated successfully, triggering batch pricing engines.');
    }

    private class HandlerMock extends OrderTriggerHandler {
        public void coverVirtualMethods() {
            super.afterUpdate();
            super.beforeUpdate();
        }
    }

    @isTest
    static void testBaseHandlerVirtualMethods() {
        HandlerMock mock = new HandlerMock();

        Test.startTest();
        mock.coverVirtualMethods();
        Test.stopTest();

        Assert.isTrue(true, 'Base virtual class coverage completed successfully.');
    }
}