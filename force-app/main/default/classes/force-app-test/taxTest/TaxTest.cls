@isTest
private class TaxTest {

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

        Tax__c tax = (Tax__c) TestFactorySObject.getInstance().createSObject(new Tax__c());
        tax.DistributionCenter__c = dc.Id;
        tax.Product__c = product.Id;
        tax.State__c = state.Id;
        insert tax;
    }

    @isTest
    static void shouldCreateTax() {
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        Tax__c tax = [SELECT Id, Name, DistributionCenter__c, Product__c, State__c, TaxCost__c FROM Tax__c LIMIT 1];

        Assert.isNotNull(tax.Id, 'Tax should have been created in test setup');
        Assert.isNotNull(tax.Name, 'Tax should have a Name field populated');
        Assert.isNotNull(tax.TaxCost__c, 'Tax should have a TaxCost__c field populated');

        Assert.isTrue(tax.TaxCost__c > 0);

        Assert.areEqual(tax.DistributionCenter__c, dc.Id, 'Tax should be associated with the correct Distribution Center');
        Assert.areEqual(tax.Product__c, product.Id, 'Tax should be associated with the correct Product');
        Assert.areEqual(tax.State__c, state.Id, 'Tax should be associated with the correct State');
    }
}