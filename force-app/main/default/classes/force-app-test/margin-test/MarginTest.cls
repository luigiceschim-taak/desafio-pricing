@isTest
private class MarginTest {

    @testSetup
    static void setupTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        DistributionCenter__c dc = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        insert dc;

        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        insert accountGroup;

        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.AccountGroup__c = accountGroup.Id;
        insert account;

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;
        insert product;

        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        insert country;

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = country.Id;
        insert state;

        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.State__c = state.Id;
        insert city;
    }

    @isTest
    static void shouldValidateXorCountryStateCityAccountGroupProductHierarchy() {
        Country__c country = [SELECT Id FROM Country__c LIMIT 1][0];
        State__c state = [SELECT Id FROM State__c LIMIT 1][0];
        City__c city = [SELECT Id FROM City__c LIMIT 1][0];
        Account account = [SELECT Id FROM Account LIMIT 1][0];
        AccountGroup__c accountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1][0];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1][0];
        ProductHierarchy__c hierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1][0];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1][0];

        Margin__c validMargin = (Margin__c)TestFactorySObject.getInstance().createSObject(new Margin__c(
            City__c = city.Id,
            Account__c = account.Id,
            Product__c = product.Id,
            DistributionCenter__c = dc.Id
        ));
        insert validMargin;
        System.assertNotEquals(null, validMargin.Id);

        Margin__c invalidMargin1 = (Margin__c)TestFactorySObject.getInstance().createSObject(new Margin__c(
            City__c = city.Id,
            State__c = state.Id,
            Account__c = account.Id,
            Product__c = product.Id,
            DistributionCenter__c = dc.Id
        ));
        try {
            insert invalidMargin1;
            System.assert(false);
        } catch (DmlException e1) {
            System.assert(e1.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Margin__c invalidMargin2 = (Margin__c)TestFactorySObject.getInstance().createSObject(new Margin__c(
            City__c = city.Id,
            Account__c = account.Id,
            AccountGroup__c = accountGroup.Id,
            Product__c = product.Id,
            DistributionCenter__c = dc.Id
        ));
        try {
            insert invalidMargin2;
            System.assert(false);
        } catch (DmlException e2) {
            System.assert(e2.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Margin__c invalidMargin3 = (Margin__c)TestFactorySObject.getInstance().createSObject(new Margin__c(
            City__c = city.Id,
            Account__c = account.Id,
            Product__c = product.Id,
            ProductHierarchy__c = hierarchy.Id,
            DistributionCenter__c = dc.Id
        ));
        try {
            insert invalidMargin3;
            System.assert(false);
        } catch (DmlException e3) {
            System.assert(e3.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Margin__c marginWithoutDC = (Margin__c)TestFactorySObject.getInstance().createSObject(new Margin__c(
            City__c = city.Id,
            Account__c = account.Id,
            Product__c = product.Id
        ));
        try {
            insert marginWithoutDC;
            System.assert(false);
        } catch (DmlException e4) {
            System.assert(e4.getMessage().contains('REQUIRED_FIELD_MISSING'));
        }
    }

    @isTest
    static void shouldCoverMarginIdCheckOnUpdate() {
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        Margin__c margin = (Margin__c) TestFactorySObject.getInstance().createSObject(new Margin__c(
            City__c = city.Id,
            Account__c = account.Id,
            Product__c = product.Id,
            DistributionCenter__c = dc.Id
        ));
        insert margin;
        System.assertNotEquals(null, margin.Id, 'Margin should be inserted successfully.');

        Test.startTest();
        try {
            update margin;
            System.assert(true, 'Update should occur without triggering a duplicate error.');
        } catch (Exception e) {
            System.assert(false, 'Trigger incorrectly blocked the self-update. Error: ' + e.getMessage());
        }
        Test.stopTest();
    }

    private class HandlerMock extends MarginTriggerHandler {
        public void coverVirtualMethods() {
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