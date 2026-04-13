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

    @TestSetup
    static void makeData(){
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;
    }

    @isTest
    static void shouldCreateEstado() {

        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
            estado.Pais__c = pais.Id;
       
        // Arrange
        
       
        
        Test.startTest();
        try{
            insert estado;

            Estado__c actual = [SELECT Id, Name, Sigla__c, Pais__c FROM Estado__c WHERE Id = :estado.Id LIMIT 1];


            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);

            Assert.isNotNull(actual.Id, 'Expected: Id Shouldnt be null');
            Assert.areEqual(estado.Name, actual.Name, 'Expected: Name should match');
            Assert.areEqual(estado.Sigla__c, actual.Sigla__c, 'Expected: Sigla__c should match');
            Assert.areEqual(estado.Pais__c, actual.Pais__c, 'Expected: Pais__c should match');

            System.debug('Sucessfully validated inserted Estado__c with Id: ' + estado.Id);


            
        }catch(DmlException e){

            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());

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
            Assert.fail('Expected: DmlException was not thrown');
       
        }catch(DmlException e){
            
            Assert.isNull(estado.Pais__c, 'Expected: Pais__c should be null');
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingEstadoWithoutName() {
        // Arrange

        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Name = null;
        estado.Pais__c = pais.Id;
        
        Test.startTest();
        try{
            insert estado;
            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);
            Assert.fail('Expected: DmlException was not thrown');       
        }catch(DmlException e){
        
            Assert.isNull(estado.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected: DmlException should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');


       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingEstadoWithoutSigla() {

        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
       
        // Arrange
        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        estado.Sigla__c = null;

        Test.startTest();
        try{
            insert estado;
            System.debug('Estado__c inserted successfully with Id: ' + estado.Id);
            Assert.fail('Expected: DmlException was not thrown');       
        }catch(DmlException e){
        
            Assert.isNull(estado.Sigla__c, 'Expected: Sigla__c should be null');
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');


       }
       Test.stopTest();
    }
}