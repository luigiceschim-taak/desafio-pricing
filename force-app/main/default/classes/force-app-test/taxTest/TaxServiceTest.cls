@isTest
private class TaxServiceTest {

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

        DistributionCenter__c dc2 = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        insert dc2;

        Country__c country2 = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        insert country2;

        State__c state2 = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state2.Country__c = country2.Id;
        insert state2;

        Tax__c tax2 = (Tax__c) TestFactorySObject.getInstance().createSObject(new Tax__c());
        tax2.DistributionCenter__c = dc2.Id;
        tax2.Product__c = product.Id;
        tax2.State__c = state2.Id;
        tax2.Name = 'Tax2';
        insert tax2;
    }

    @isTest
    static void shouldFailWhenDataAlreadyExistsInTheSameBatch() {
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        Tax__c duplicateTax = new Tax__c(
            Name = 'Duplicate Tax',
            DistributionCenter__c = dc.Id,
            Product__c = product.Id,
            State__c = state.Id,
            TaxCost__c = 10
        );
        Tax__c duplicateTax2 = new Tax__c(
            Name = 'Duplicate Tax',
            DistributionCenter__c = dc.Id,
            Product__c = product.Id,
            State__c = state.Id,
            TaxCost__c = 10
        );

        try{
            insert new List<Tax__c>{duplicateTax, duplicateTax2};
            System.assert(false, 'Expected an exception due to duplicate records, but none was thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected error message about duplicate records, but got: ' + e.getMessage());
        }
    }

    @isTest
    static void shouldFailWhenTaxCostIsZeroOrLessOnUpdate(){
        Tax__c tax = [SELECT Id, Name, DistributionCenter__c, Product__c, State__c, TaxCost__c FROM Tax__c LIMIT 1];
        tax.TaxCost__c = 0;

        List<Tax__c> taxesToUpdate = new List<Tax__c>();
        taxesToUpdate.add(tax);

        try{
            update taxesToUpdate;
            System.assert(false, 'Expected an exception due to TaxCost__c being zero, but none was thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('O valor do Imposto de Custo deve ser maior que zero.'), 'Expected error message about TaxCost__c being greater than zero, but got: ' + e.getMessage());
        }
    }

    @isTest
    static void shouldFailWhenDataAlreadyExistsInTheSameBatchAfterUpdate() {
        Tax__c tax = [SELECT Id, Name, DistributionCenter__c, Product__c, State__c, TaxCost__c FROM Tax__c LIMIT 1];
        Tax__c tax2 = [SELECT Id, Name, DistributionCenter__c, Product__c, State__c, TaxCost__c FROM Tax__c WHERE Name = 'Tax2' LIMIT 1];

        try {
            tax.Name = 'Duplicate Tax';
            tax.DistributionCenter__c = tax2.DistributionCenter__c;
            tax.State__c = tax2.State__c;
            tax.Product__c = tax2.Product__c;
            update tax;
            System.assert(false, 'Expected an exception due to duplicate records, but none was thrown.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Expected error message about duplicate records, but got: ' + e.getMessage()
            );
        }
    }
}