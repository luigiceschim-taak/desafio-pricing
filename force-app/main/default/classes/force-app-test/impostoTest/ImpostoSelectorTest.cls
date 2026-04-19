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
private class ImpostoSelectorTest {

    @testSetup
    static void setupTestData() {

        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        
        Centro_de_Distribuicao__c centro = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert centro;

        Hierarquia_Produto__c hierarquia = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquia;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.Hierarquia_Produto__c = hierarquia.Id;
        insert product;

        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        insert estado;  
    }


    @isTest
    static void shouldRetrieveImposto() {

        Set<Id> produtosIds = new Set<Id>();
        Set<Id> locaisIds = new Set<Id>();
        Set<Id> cdsIds = new Set<Id>();

        

        Centro_de_Distribuicao__c centro = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];

        Imposto__c imposto = (Imposto__c) TestFactorySObject.getInstance().createSObject(new Imposto__c());
        imposto.Centro_Distribuicao__c = centro.Id;
        imposto.Product__c = product.Id;
        imposto.Estado__c = estado.Id;
        insert imposto;


        Imposto__c impostoC = [SELECT Id, Name, Centro_Distribuicao__c, Product__c, Estado__c,Imposto_Custo__c  FROM Imposto__c LIMIT 1];


        for(Centro_de_Distribuicao__c cd : [SELECT Id FROM Centro_de_Distribuicao__c]) {
            System.debug('Centro de Distribuição: ' + cd.Id);
            cdsIds.add(cd.Id);
            
        }
        for(Product2 p : [SELECT Id FROM Product2]) {
            System.debug('Produto: ' + p.Id);
            produtosIds.add(p.Id);
        }
        for(Estado__c e : [SELECT Id FROM Estado__c]) {
            System.debug('Estado: ' + e.Id);
            locaisIds.add(e.Id);
        }

        

        Map<String, Imposto__c> impostos = ImpostoSelector.getMapaRegras(produtosIds, locaisIds, cdsIds);

        String chaveMestra = String.valueOf(imposto.Product__c) + 
                         String.valueOf(imposto.Centro_Distribuicao__c) + 
                         String.valueOf(imposto.Estado__c);

        Assert.isTrue(impostos.containsKey(chaveMestra));
    }
}