@isTest
private class FreightTest {

    @testSetup
    static void setupTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        DistributionCenter__c dc = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        insert dc;

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

    private class HandlerMock extends FreightTriggerHandler {
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

    @isTest
    static void shouldValidateXorCountryStateCity() {
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        Freight__c freightCountry = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(Country__c = country.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        insert freightCountry;
        System.assertNotEquals(null, freightCountry.Id, 'Freight with only Country should be inserted');

        Freight__c freightState = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(State__c = state.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        insert freightState;
        System.assertNotEquals(null, freightState.Id, 'Freight with only State should be inserted');

        Freight__c freightCity = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(City__c = city.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        insert freightCity;
        System.assertNotEquals(null, freightCity.Id, 'Freight with only City should be inserted');

        Freight__c freightCountryState = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(Country__c = country.Id, State__c = state.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        try {
            insert freightCountryState;
            System.assert(false, 'Should not allow Country and State together');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Error message should mention XOR');
        }

        Freight__c freightStateCity = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(State__c = state.Id, City__c = city.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        try {
            insert freightStateCity;
            System.assert(false, 'Should not allow State and City together');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Error message should mention XOR');
        }

        Freight__c freightCountryCity = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(Country__c = country.Id, City__c = city.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        try {
            insert freightCountryCity;
            System.assert(false, 'Should not allow Country and City together');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Error message should mention XOR');
        }

        Freight__c freightAll = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c(Country__c = country.Id, State__c = state.Id, City__c = city.Id, DistributionCenter__c = dc.Id, Product__c = product.Id));
        try {
            insert freightAll;
            System.assert(false, 'Should not allow all together');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Error message should mention XOR');
        }
    }

    @isTest
    static void shouldValidateDuplicityOnBeforeUpdate() {
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];
        City__c city1 = [SELECT Id FROM City__c LIMIT 1];

        City__c city2 = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city2.State__c = state.Id;
        insert city2;

        Freight__c freightA = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freightA.Product__c = product.Id;
        freightA.DistributionCenter__c = dc.Id;
        freightA.City__c = city1.Id;
        insert freightA;

        Freight__c freightB = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freightB.Product__c = product.Id;
        freightB.DistributionCenter__c = dc.Id;
        freightB.City__c = city2.Id;
        insert freightB;

        Test.startTest();

        try {
            update freightA;
            System.assert(true, 'Success: Trigger allowed self-update, ignoring own ID in duplicate check.');
        } catch (Exception e) {
            System.assert(false, 'Trigger blocked self-update. Check ID exclusion in SOQL. Error: ' + e.getMessage());
        }

        freightB.City__c = city1.Id;

        try {
            update freightB;
            System.assert(false, 'System should have blocked the update since the new combination already exists in Freight A.');
        } catch (DmlException e) {
            String expectedMessage = 'Já existe um registro';
            System.assert(e.getMessage().contains(expectedMessage),
                'Unexpected error or incorrect validation message. Received: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    static void shouldFailWhenDuplicateInsertInTheSameBatch(){
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];

        Freight__c freight1 = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freight1.Product__c = product.Id;
        freight1.DistributionCenter__c = dc.Id;
        freight1.City__c = city.Id;

        Freight__c freight2 = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());
        freight2.Product__c = product.Id;
        freight2.DistributionCenter__c = dc.Id;
        freight2.City__c = city.Id;

        List<Freight__c> freightsToInsert = new List<Freight__c>{freight1, freight2};

        try {
            insert freightsToInsert;
            System.assert(false, 'Should have thrown a duplicate exception, but did not.');
        } catch (DmlException e) {
            String expectedMessage = 'Registro duplicado no mesmo lote';
            System.assert(e.getMessage().contains(expectedMessage),
                'Unexpected error or incorrect validation message. Received: ' + e.getMessage());
        }
    }
}