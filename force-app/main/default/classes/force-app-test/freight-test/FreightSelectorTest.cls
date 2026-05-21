@isTest
private class FreightSelectorTest {

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

    @isTest
    static void shouldMapAll6FreightCombinations() {
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        ProductHierarchy__c hierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];

        List<Freight__c> freightsToInsert = new List<Freight__c>();

        freightsToInsert.add(createFreightHelper(dc.Id, product.Id, null, city.Id, null, null));
        freightsToInsert.add(createFreightHelper(dc.Id, product.Id, null, null, state.Id, null));
        freightsToInsert.add(createFreightHelper(dc.Id, product.Id, null, null, null, country.Id));

        freightsToInsert.add(createFreightHelper(dc.Id, null, hierarchy.Id, city.Id, null, null));
        freightsToInsert.add(createFreightHelper(dc.Id, null, hierarchy.Id, null, state.Id, null));
        freightsToInsert.add(createFreightHelper(dc.Id, null, hierarchy.Id, null, null, country.Id));

        insert freightsToInsert;

        Set<Id> productsIds = new Set<Id>{ product.Id };
        Set<Id> hierarchiesIds = new Set<Id>{ hierarchy.Id };
        Set<Id> dcsIds = new Set<Id>{ dc.Id };
        Set<Id> locationsIds = new Set<Id>{ city.Id, state.Id, country.Id };

        Test.startTest();
        Map<String, Freight__c> returnedMap = FreightSelector.getRulesMap(productsIds, hierarchiesIds, locationsIds, dcsIds);
        Test.stopTest();

        Assert.areEqual(6, returnedMap.size(), 'The map should contain exactly 6 unique freight combinations.');

        Assert.isTrue(returnedMap.containsKey(String.valueOf(product.Id) + String.valueOf(city.Id)), 'Missing key: Product + City');
        Assert.isTrue(returnedMap.containsKey(String.valueOf(product.Id) + String.valueOf(state.Id)), 'Missing key: Product + State');
        Assert.isTrue(returnedMap.containsKey(String.valueOf(product.Id) + String.valueOf(country.Id)), 'Missing key: Product + Country');

        Assert.isTrue(returnedMap.containsKey(String.valueOf(hierarchy.Id) + String.valueOf(city.Id)), 'Missing key: Hierarchy + City');
        Assert.isTrue(returnedMap.containsKey(String.valueOf(hierarchy.Id) + String.valueOf(state.Id)), 'Missing key: Hierarchy + State');
        Assert.isTrue(returnedMap.containsKey(String.valueOf(hierarchy.Id) + String.valueOf(country.Id)), 'Missing key: Hierarchy + Country');
    }

    private static Freight__c createFreightHelper(Id dcId, Id productId, Id hierarchyId, Id cityId, Id stateId, Id countryId) {
        Freight__c f = (Freight__c) TestFactorySObject.getInstance().createSObject(new Freight__c());

        f.DistributionCenter__c = dcId;
        f.Status__c = 'Approved';

        f.Product__c = productId;
        f.ProductHierarchy__c = hierarchyId;

        f.City__c = cityId;
        f.State__c = stateId;
        f.Country__c = countryId;

        return f;
    }
}