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

    @TestSetup
    static void makeData(){
        Grupo_Conta__c grupo = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupo;
    }

    @isTest
    static void shouldFailWhenAccountWillBeCreatedWithInvalidCNPJ() {
        // Arrange

        Grupo_Conta__c grupo = [SELECT Id FROM Grupo_Conta__c LIMIT 1];

        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.Grupo_Clientes__c = grupo.Id;
        acc.CNPJ__c = '00000000000001';


        
        try {
            insert acc;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());

            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem deve mencionar FIELD_CUSTOM_VALIDATION_EXCEPTION');
            
        }
    }

    @isTest
    static void shouldFailWhenAccountWillBeCreatedWithoutAccountGroup() {

    
        
        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.Grupo_Clientes__c = null; 

        try {
            insert acc;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.isNull(acc.Grupo_Clientes__c);
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Mensagem deve mencionar REQUIRED_FIELD_MISSING');}
    }

    @isTest
    static void shouldCreateAccountWithAccountGroupCNPJName() {

        Grupo_Conta__c grupo = [SELECT Id FROM Grupo_Conta__c LIMIT 1];

        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.Grupo_Clientes__c = grupo.Id;
        
        
        try{
            insert acc;
            System.debug('Account inserted successfully with Id: ' + acc.Id);

            Account actual = [SELECT Id, Name, CNPJ__c, Grupo_Clientes__c FROM Account WHERE Id = :acc.Id LIMIT 1];

            Assert.isNotNull(actual.Id, 'Expected: Id should not be null');
            Assert.areEqual(acc.Name, actual.Name, 'Expected: Name should match');
            Assert.areEqual(acc.CNPJ__c, actual.CNPJ__c, 'Expected: CNPJ__c should match');
            Assert.areEqual(acc.Grupo_Clientes__c, actual.Grupo_Clientes__c, 'Expected: Grupo_Clientes__c should match');

            System.debug('Successfully validated inserted Account with Id: ' + acc.Id);

        }catch(DmlException e){
            System.debug('Unexpected DmlException was thrown: ' + e.getMessage());
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());

        }
    }

}  
