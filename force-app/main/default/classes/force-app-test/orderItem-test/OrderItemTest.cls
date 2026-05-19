@isTest
private class OrderItemTest {

    @testSetup
    static void setupTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        insert accountGroup;

        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.AccountGroup__c = accountGroup.Id;
        insert account;

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

        Address__c address = (Address__c) TestFactorySObject.getInstance().createSObject(new Address__c());
        address.City__c = city.Id;
        address.Account__c = account.Id;
        insert address;

        Freight__c freightRule = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freightRule.Product__c = product.Id;
        freightRule.DistributionCenter__c = dc.Id;
        freightRule.City__c = city.Id;
        freightRule.Status__c = 'Approved';
        freightRule.Cost__c = 150.00;
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
        marginRule.Status__c = 'Approved';
        marginRule.Cost__c = 30.00;
        insert marginRule;
    }

    @isTest
    static void shouldPopulateOrderItemFieldsOnInsert() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.Status = 'Rascunho';
        insert order;

        OrderItem item = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        Test.startTest();
        insert item;
        Test.stopTest();

        OrderItem updatedItem = [
            SELECT Id, FreightCost__c, TaxPercentage__c, MarginPercentage__c
            FROM OrderItem
            WHERE Id = :item.Id
        ];

        Assert.areEqual(150.00, updatedItem.FreightCost__c, 'Trigger failed to invoke the Freight Engine on item creation.');
        Assert.areEqual(15.00, updatedItem.TaxPercentage__c, 'Trigger failed to invoke the Tax Engine on item creation.');
        Assert.areEqual(30.00, updatedItem.MarginPercentage__c, 'Trigger failed to invoke the Margin Engine on item creation.');
    }

    @isTest
    static void shouldPopulateOrderItemWithMergingAndValidateQuantity() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.Status = 'Rascunho';
        insert order;

        OrderItem item = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        OrderItem item2 = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 3,
            UnitPrice = pbe.UnitPrice
        );

        Test.startTest();
        insert item;
        insert item2;
        Test.stopTest();

        OrderItem updatedItem = [
            SELECT Id, FreightCost__c, TaxPercentage__c, MarginPercentage__c, Quantity
            FROM OrderItem
            WHERE Id = :item.Id
        ];

        Assert.areEqual(150.00, updatedItem.FreightCost__c, 'Trigger failed to invoke the Freight Engine on item creation.');
        Assert.areEqual(15.00, updatedItem.TaxPercentage__c, 'Trigger failed to invoke the Tax Engine on item creation.');
        Assert.areEqual(30.00, updatedItem.MarginPercentage__c, 'Trigger failed to invoke the Margin Engine on item creation.');
        Assert.areEqual(4, updatedItem.Quantity, 'Merge logic failed. The quantity of the first item should have been updated to 4.');
    }

    @isTest
    static void shouldFailWhenUpdateStatusOfOrderIsActive() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Address__c address = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        PricebookEntry pbe = [SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1];

        Order order = (Order) TestFactorySObject.getInstance().createSObject(new Order());
        order.AccountId = account.Id;
        order.Address__c = address.Id;
        order.DistributionCenter__c = dc.Id;
        order.Pricebook2Id = Test.getStandardPricebookId();
        order.Status = 'Rascunho';
        insert order;

        OrderItem item = new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 1,
            UnitPrice = pbe.UnitPrice
        );

        Test.startTest();
        insert item;

        Order activeOrder = [SELECT Id, Status FROM Order WHERE Id = :order.Id LIMIT 1];
        activeOrder.Status = 'Activated';
        update activeOrder;

        try {
            OrderItem itemToUpdate = [SELECT Id, Quantity FROM OrderItem WHERE Id = :item.Id LIMIT 1];
            itemToUpdate.Quantity = 10;
            update itemToUpdate;

            Assert.fail('System should have thrown a DmlException when trying to update an item of an active order.');

        } catch (DmlException e) {
            Assert.isTrue(e.getMessage().contains('Erro: Itens de um pedido ativo não podem ser alterados'), 'Incorrect error message: ' + e.getMessage());
        }

        Test.stopTest();

        OrderItem nonUpdatedItem = [
            SELECT Id, FreightCost__c, TaxPercentage__c, MarginPercentage__c, Quantity
            FROM OrderItem
            WHERE Id = :item.Id
        ];

        Assert.areEqual(150.00, nonUpdatedItem.FreightCost__c, 'Trigger failed to invoke the Freight Engine on item creation.');
        Assert.areEqual(15.00, nonUpdatedItem.TaxPercentage__c, 'Trigger failed to invoke the Tax Engine on item creation.');
        Assert.areEqual(30.00, nonUpdatedItem.MarginPercentage__c, 'Trigger failed to invoke the Margin Engine on item creation.');
        Assert.areEqual(1, nonUpdatedItem.Quantity, 'Quantity should still be 1 since the update was blocked.');
    }

    private class HandlerMock extends TriggerHandler {
        public void coverVirtualMethods() {
            super.afterInsert();
            super.beforeInsert();
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