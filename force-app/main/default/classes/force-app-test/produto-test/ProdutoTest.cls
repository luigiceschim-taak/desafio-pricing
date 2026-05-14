@isTest
private class ProdutoTest {

    @TestSetup
    static void makeData(){
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;
    }

    @isTest
    static void shouldCreateProduct() {
        ProductHierarchy__c hierarchy = [SELECT Id FROM ProductHierarchy__c LIMIT 1];

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.ProductHierarchy__c = hierarchy.Id;

        try {
            insert product;

            Assert.isNotNull(product.Id, 'Product should have been created');
            Assert.isNotNull(product.ProductHierarchy__c, 'Product should have a reference to ProductHierarchy');
            Assert.isNotNull(product.Name, 'Product should have a Name value');

        } catch (DmlException e) {
            Assert.fail(e.getMessage());
        }
    }
}