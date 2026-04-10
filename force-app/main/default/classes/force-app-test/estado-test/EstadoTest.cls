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
private class EstadoTest {

    @isTest
    static void shouldCreateEstado() {

        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;
       
        // Arrange
        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
       
        
        Test.startTest();
        try{
            insert estado;
            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);
            System.assert(true,'Expected: SUCCESS');
       
        }catch(DmlException e){

            System.assert(false,'Unexpected DmlException was thrown: ' + e.getMessage());

       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingEstadoWithoutPais() {
        
        // Arrange
        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = null;

        Test.startTest();
        try{
            insert estado;
            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);
            System.assert(false,'Unexpected: estado was inserted without a Pais__c');
       
        }catch(DmlException e){
            System.assert(true,'Expected DmlException was thrown: ' + e.getMessage());

       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingEstadoWithoutName() {
        // Arrange

        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Name = null;
        estado.Pais__c = pais.Id;
        
        Test.startTest();
        try{
            insert estado;
            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);
            System.assert(false,'Expected: DmlException was not thrown');
       
        }catch(DmlException e){
        
            System.assert(true,'Unexpected DmlException was thrown: ' + e.getMessage());


       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingEstadoWithoutSigla() {

        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;
       
        // Arrange
        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        estado.Sigla__c = null;

        Test.startTest();
        try{
            insert estado;
            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);
            System.assert(false,'Expected: DmlException was not thrown');
       
        }catch(DmlException e){
        
            System.assert(true,'Unexpected DmlException was thrown: ' + e.getMessage());


       }
       Test.stopTest();
    }
}