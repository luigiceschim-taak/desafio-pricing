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
private class GrupoContaTest {

    @isTest
    static void shouldCreateGrupoConta() {
        // Arrange
        Grupo_Conta__c grupo = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        
        Test.startTest();
        try {
            insert grupo;
            System.debug('Grupo_Conta__c inserted successfully with Id: ' + grupo.Id);

            Grupo_Conta__c actual = [SELECT Id, Name FROM Grupo_Conta__c WHERE Id = :grupo.Id LIMIT 1];

            Assert.areEqual(grupo.Id, actual.Id, 'Expected: Id should match');
            Assert.areEqual(grupo.Name, actual.Name, 'Expected: Name should match');
        }catch(DmlException e){
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenGrupoContaWillBeCreatedWithoutName() {
        // TO DO: implement unit test

        Grupo_Conta__c grupo = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        grupo.Name = null;
        
        Test.startTest();
        try {
            insert grupo;
            Assert.fail('Erro: conta inserida em teste de criar sem nome');
        }catch (DmlException e) {
            
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem deve mencionar Name');          
        }
        Test.stopTest();
    }
}