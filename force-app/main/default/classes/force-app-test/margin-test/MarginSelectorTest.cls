@isTest
private class MarginSelectorTest {

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
    }

    @isTest
    static void shouldMapAll12MarginCombinations() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        ProductHierarchy__c hierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        AccountGroup__c accountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        List<Id> productOptions = new List<Id>{ product.Id, hierarchy.Id };
        List<Id> accountOptions = new List<Id>{ account.Id, accountGroup.Id };
        List<Id> geoOptions = new List<Id>{ city.Id, state.Id, country.Id };

        List<Margin__c> marginsToInsert = new List<Margin__c>();

        for (Id pTarget : productOptions) {
            for (Id aTarget : accountOptions) {
                for (Id gTarget : geoOptions) {
                    marginsToInsert.add(createMarginHelper(
                        (pTarget == product.Id) ? product.Id : null,
                        (pTarget == hierarchy.Id) ? hierarchy.Id : null,
                        (aTarget == account.Id) ? account.Id : null,
                        (aTarget == accountGroup.Id) ? accountGroup.Id : null,
                        (gTarget == city.Id) ? city.Id : null,
                        (gTarget == state.Id) ? state.Id : null,
                        (gTarget == country.Id) ? country.Id : null,
                        dc.Id
                    ));
                }
            }
        }
        insert marginsToInsert;

        Set<Id> productsIds = new Set<Id>{ product.Id, hierarchy.Id };
        Set<Id> accountsIds = new Set<Id>{ account.Id };
        Set<Id> accountGroupsIds = new Set<Id>{ accountGroup.Id };
        Set<Id> locationsIds = new Set<Id>{ city.Id, state.Id, country.Id };
        Set<Id> dcsIds = new Set<Id>{ dc.Id };

        Test.startTest();
        Map<String, Margin__c> returnedMap = MarginSelector.getMapaRegras(productsIds, new Set<Id>(), locationsIds, dcsIds, accountsIds, accountGroupsIds);
        Test.stopTest();

        Assert.areEqual(12, returnedMap.size(), 'Should contain exactly 12 combinations.');

        for (Id pTarget : productOptions) {
            for (Id aTarget : accountOptions) {
                for (Id gTarget : geoOptions) {
                    String expectedKey = String.valueOf(pTarget) + String.valueOf(aTarget) + String.valueOf(dc.Id) + String.valueOf(gTarget);
                    Assert.isTrue(returnedMap.containsKey(expectedKey),
                        'Failed to map key: ' + expectedKey);
                }
            }
        }
    }

    @isTest
    static void shouldFailWhenInsertDuplicateInBatch() {
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];

        List<Margin__c> marginsToInsert = new List<Margin__c>();

        marginsToInsert.add(createMarginHelper(product.Id, null, account.Id, null, city.Id, null, null, dc.Id));
        marginsToInsert.add(createMarginHelper(product.Id, null, account.Id, null, city.Id, null, null, dc.Id));

        try {
            insert marginsToInsert;
            Assert.fail('Should have thrown a duplicate exception, but did not.');
        } catch (DmlException e) {
            System.debug('Exception captured as expected: ' + e.getMessage());
        }
    }

    private static Margin__c createMarginHelper(Id productId, Id hierarchyId, Id accountId, Id accountGroupId, Id cityId, Id stateId, Id countryId, Id dcId) {
        Margin__c m = (Margin__c) TestFactorySObject.getInstance().createSObject(new Margin__c());

        m.Status__c = 'Approved';
        m.DistributionCenter__c = dcId;

        m.Product__c = productId;
        m.ProductHierarchy__c = hierarchyId;

        m.Account__c = accountId;
        m.AccountGroup__c = accountGroupId;

        m.City__c = cityId;
        m.State__c = stateId;
        m.Country__c = countryId;

        return m;
    }
}