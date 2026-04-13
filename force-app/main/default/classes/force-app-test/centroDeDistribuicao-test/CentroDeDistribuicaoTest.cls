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
private class CentroDeDistribuicaoTest {


    @isTest
    static void shouldCreateCentroDeDistribuicao() {
        Centro_de_Distribuicao__c cd = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
    
        try{
            insert cd;

            Centro_de_Distribuicao__c cdInserted = [SELECT Id, Name, Codigo__c FROM Centro_de_Distribuicao__c WHERE Id = :cd.Id];

            
            System.debug('Centro de Distribuição inserido: ' + cdInserted + cdInserted.Id + cdInserted.Codigo__c);
            Assert.isNotNull(cdInserted.Codigo__c, 'Expected: Centro de Distribuição should be inserted');
            Assert.isNotNull(cdInserted.Id, 'Expected: Id should not be null');
            Assert.areEqual(cd.Name, cdInserted.Name, 'Expected: Name should match the default value');
        
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.fail('Expected: DmlException was not expected');
        }
    }


    @isTest
    static void shouldFailWhenCreatingCDWithoutName() {
        Centro_de_Distribuicao__c cd = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        cd.Name = null;

        try {
            insert cd;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Erro esperado: ' + e.getMessage());
            Assert.isNull(cd.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem deve mencionar FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
    }
}