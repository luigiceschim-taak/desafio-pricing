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
    static void shouldCreateCidade() {
        // Arrange
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        
        Test.startTest();
        try{
            insert cidade;

            Cidade__c actual = [SELECT Id, Name, Codigo_IBGE__c, Estado__c FROM Cidade__c WHERE Id = :cidade.Id LIMIT 1];

            System.debug('Cidade__c inserted successfully with Id: ' + cidade.Id);

            Assert.isNotNull(actual.Id, 'Expected: Id should not be null');
            Assert.areEqual(cidade.Name, actual.Name, 'Expected: Name should match');
            Assert.areEqual(cidade.Codigo_IBGE__c, actual.Codigo_IBGE__c, 'Expected: Codigo_IBGE__c should match');
            Assert.areEqual(cidade.Estado__c, actual.Estado__c, 'Expected: Estado__c should match');

            System.debug('Successfully validated inserted Cidade__c with Id: ' + cidade.Id);
        }catch(DmlException e){

            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());

       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCidadeWithoutEstado() {
        // Arrange
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = null;

        
        Test.startTest();
        try{
            insert cidade;
            System.debug('Cidade__c inserted successfully with Id: ' + cidade.Id);
            Assert.fail('Deveria ter lançado uma DmlException devido à falta do Estado__c');
       
        }catch(DmlException e){

            Assert.isNull(cidade.Estado__c);
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');

       }
       Test.stopTest();
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

            Assert.isNull(cidade.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected: DmlException should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
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
            
            Assert.fail('Should have thrown a DmlException due to missing Codigo_IBGE__c');
        }catch(DmlException e){
            System.debug('Expected DmlException was thrown: ' + e.getMessage());
            
            Assert.isNull(cidade.Codigo_IBGE__c);
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');
        }
        Test.stopTest();
    }
}