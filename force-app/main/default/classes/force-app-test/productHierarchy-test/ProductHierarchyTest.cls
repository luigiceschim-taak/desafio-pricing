@isTest
private class ProductHierarchyTest {

    @TestSetup
    static void makeData(){
        ProductHierarchy__c hierarchy = (ProductHierarchy__c) TestFactorySObject.getInstance().createSObject(new ProductHierarchy__c());
        insert hierarchy;
    }

    @isTest
    static void shouldCreateProductHierarchy() {
        ProductHierarchy__c hierarchy = [SELECT Id, Name, Code__c FROM ProductHierarchy__c LIMIT 1];

        Assert.isNotNull(hierarchy.Id, 'Product Hierarchy should have been created');
        Assert.isNotNull(hierarchy.Code__c, 'Product Hierarchy should have a Code__c value');
        Assert.isNotNull(hierarchy.Name, 'Product Hierarchy should have a Name value');
    }
}