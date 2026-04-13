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
private class CondicaoPagamentoTest {

    @isTest 
    static void shouldCreateCondicaoPagamento() {
        Condicao_Pagamento__c cp = (Condicao_Pagamento__c) TestFactorySObject.getInstance().createSObject(new Condicao_Pagamento__c());
    
        try{
            insert cp;

            Condicao_Pagamento__c cpInserted = [SELECT Id, Name, Condicao_Pagamento__c FROM Condicao_Pagamento__c WHERE Id = :cp.Id];

            
            System.debug('Condição de Pagamento inserida: ' + cpInserted + cpInserted.Id);
            Assert.isNotNull(cpInserted.Id, 'Expected: Id should not be null');
            Assert.isNotNull(cpInserted.Condicao_Pagamento__c, 'Expected: Condição de Pagamento should be inserted');
            Assert.areEqual(cp.Name, cpInserted.Name, 'Expected: Name should match the default value');
        
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.fail('Expected: DmlException was not expected');
        }
    }

    @isTest
    static void shouldFailWhenCreatingCondicaoPagamentoWithoutName() {
        Condicao_Pagamento__c cp = (Condicao_Pagamento__c) TestFactorySObject.getInstance().createSObject(new Condicao_Pagamento__c());
        cp.Name = null;

        try {
            insert cp;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.isNull(cp.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem deve mencionar FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
    }
}