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
private class EnderecoTest {

    @TestSetup
    static void makeData(){
        Grupo_Conta__c grupoConta = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupoConta;
        
        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.Grupo_Clientes__c = grupoConta.Id;
        insert account;

        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        insert estado;

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        insert cidade;
        
    }

    @isTest
    static void shouldCreateEndereco() {

        Account account = [SELECT Id FROM Account LIMIT 1];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];
        
        Endereco__c endereco = (Endereco__c) TestFactorySObject.getInstance().createSObject(new Endereco__c());
        endereco.Account__c = account.Id;
        endereco.Cidade__c = cidade.Id;

        

        try{
            insert endereco;

            Endereco__c enderecoInserted = [SELECT Id, Name, Logradouro__c, Bairro__c, CEP__c, Account__c, Cidade__c FROM Endereco__c WHERE Id = :endereco.Id];

            
            System.debug('Endereço inserido: ' + enderecoInserted + enderecoInserted.Id);
            Assert.isNotNull(enderecoInserted.Id, 'Expected: Id should not be null');

            Assert.areEqual(endereco.Account__c, enderecoInserted.Account__c, 'Expected: Account should match the default value');
            Assert.areEqual(endereco.Cidade__c, enderecoInserted.Cidade__c, 'Expected: Cidade should match the default value');
            Assert.areEqual(endereco.Name, enderecoInserted.Name, 'Expected: Name should match the default value');
            Assert.areEqual(endereco.Logradouro__c, enderecoInserted.Logradouro__c, 'Expected: Logradouro should match the default value');
            Assert.areEqual(endereco.Bairro__c, enderecoInserted.Bairro__c, 'Expected: Bairro should match the default value');
            Assert.areEqual(endereco.CEP__c, enderecoInserted.CEP__c, 'Expected: CEP should match the default value');

        
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.fail('Expected: DmlException was not expected');
        }    
    }

    @isTest 
    static void shouldNotCreateEnderecoWithoutName() {
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];
        
        Endereco__c endereco = (Endereco__c) TestFactorySObject.getInstance().createSObject(new Endereco__c());
        endereco.Name = null; 
        endereco.Cidade__c = cidade.Id;
        endereco.Account__c = account.Id;


        try{
            insert endereco;
            Assert.fail('Expected: DmlException was expected due to missing Name');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.isNull(endereco.Name);
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected: DmlException should indicate FIELD_CUSTOM_VALIDATION_EXCEPTION Name');
        }    
    }

}