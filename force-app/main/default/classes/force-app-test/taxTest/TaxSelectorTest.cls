@isTest
private class TaxSelectorTest {

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
    }

    @isTest
    static void shouldRetrieveTax() {
        Set<Id> productsIds = new Set<Id>();
        Set<Id> locationsIds = new Set<Id>();
        Set<Id> dcsIds = new Set<Id>();

        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        Tax__c tax = (Tax__c) TestFactorySObject.getInstance().createSObject(new Tax__c());
        tax.DistributionCenter__c = dc.Id;
        tax.Product__c = product.Id;
        tax.State__c = state.Id;
        insert tax;

        Tax__c taxQueried = [SELECT Id, Name, DistributionCenter__c, Product__c, State__c, TaxCost__c FROM Tax__c LIMIT 1];

        for(DistributionCenter__c d : [SELECT Id FROM DistributionCenter__c]) {
            System.debug('Distribution Center: ' + d.Id);
            dcsIds.add(d.Id);
        }
        for(Product2 p : [SELECT Id FROM Product2]) {
            System.debug('Product: ' + p.Id);
            productsIds.add(p.Id);
        }
        for(State__c s : [SELECT Id FROM State__c]) {
            System.debug('State: ' + s.Id);
            locationsIds.add(s.Id);
        }

        Map<String, Tax__c> taxes = TaxSelector.getRulesMap(productsIds, locationsIds, dcsIds);

        String masterKey = String.valueOf(tax.Product__c) +
                         String.valueOf(tax.DistributionCenter__c) +
                         String.valueOf(tax.State__c);

        Assert.isTrue(taxes.containsKey(masterKey));
    }
}