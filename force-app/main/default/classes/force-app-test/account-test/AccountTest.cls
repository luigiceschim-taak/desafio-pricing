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
private class AccountTest {

    @isTest
    static void shouldFailWhenAccountWillBeCreatedWithInvalidCNPJ() {
        // Arrange
        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.CNPJ__c = '0000000000000000';


        // Act & Assert
        try {
            insert acc;
            System.assert(false, 'Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            System.assert(e.getMessage().contains('CNPJ'), 'Mensagem deve mencionar CNPJ');
        }
    }

    @isTest
    static void shouldFailWhenAccountWillBeCreatedWithoutAccountGroup() {

    
        // Arrange
        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());

        // Act & Assert
        try {
            insert acc;
            System.assert(false, 'Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            System.assert(e.getMessage().contains('Grupo_Clientes__c'), 'Mensagem deve mencionar Grupo de Clientes');
        }
    }

    @isTest
    static void shouldCreateAccountWithAccountGroupCNPJName() {

        // Arrange
        Grupo_Conta__c grupo = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupo;

        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        
        
        // Act
        
        acc.Grupo_Clientes__c = grupo.Id;
        
        insert acc;

        // Assert
        Account insertedAcc = [SELECT Id, Name, Grupo_Clientes__c FROM Account WHERE Id = :acc.Id];
        
        
        System.assertEquals(acc.Id, insertedAcc.Id);
        System.assertEquals(grupo.Id, insertedAcc.Grupo_Clientes__c);
    }

    
}