/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class ProdutoTest {

    @TestSetup
    static void makeData(){
        Hierarquia_Produto__c hdp = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hdp;
    }


    @isTest
    static void shouldCreateProduct() {
        Hierarquia_Produto__c hdp = [SELECT Id FROM Hierarquia_Produto__c LIMIT 1];

        Product2 produto = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        produto.Hierarquia_Produto__c = hdp.Id;

        try {
            insert produto;

            Assert.isNotNull(produto.Id, 'Produto should have been created');
            Assert.isNotNull(produto.Hierarquia_Produto__c, 'Produto should have a reference to Hierarquia de Produto');
            Assert.isNotNull(produto.Name, 'Produto should have a Name value');

        } catch (DmlException e) {
            Assert.fail(e.getMessage());
            
        }    
    }
}