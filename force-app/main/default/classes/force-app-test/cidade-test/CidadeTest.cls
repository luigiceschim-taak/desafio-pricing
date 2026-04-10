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
private class CidadeTest {

    @TestSetup
    static void makeData(){
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;

        // Create an Estado__c record linked to the Pais__c
        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        insert estado;    
    }
    
    @isTest
    static void shouldFailWhenCreatingCidadeWithoutName() {
        // Arrange
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Name = null;
        cidade.Estado__c = estado.Id;
        
        Test.startTest();
        try{
            insert cidade;
            System.debug('Cidade__c inserted successfully with Id: ' + cidade.Id);
            Assert.fail('Deveria ter lançado uma DmlException devido à falta do nome');
        }catch(DmlException e){

            Assert.isTrue(true, 'Expected DmlException was thrown: ' + e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCidadeWithoutCodigoIBGE() {
        // TO DO: implement unit test

        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Codigo_IBGE__c = null;
        cidade.Estado__c = estado.Id;
        
        Test.startTest();

        try{
            insert cidade;
            
            Assert.fail('Deveria ter lançado uma DmlException devido à falta do Código IBGE');
        }catch(DmlException e){
            System.debug('Expected DmlException was thrown: ' + e.getMessage());
            Assert.isTrue(true, 'exceção deve mencionar o campo' + e.getMessage());
        }
        Test.stopTest();
    }
}