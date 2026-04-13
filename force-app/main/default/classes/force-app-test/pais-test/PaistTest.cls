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
private class PaistTest {

    @isTest
    static void shouldCreatePais() {
        // Arrange
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());

        Test.startTest();

        

       try{
            insert pais;
            System.debug('Pais__c inserted successfully with Id: ' + pais.Id);

            Pais__c actual = [SELECT Id, Sigla__c, Name FROM Pais__c WHERE Id = :pais.Id LIMIT 1];

            Assert.areEqual(pais.Id, actual.Id, 'Expected: Id should match');
            Assert.areEqual(pais.Sigla__c, actual.Sigla__c, 'Expected: Sigla__c should match');
            Assert.areEqual(pais.Name, actual.Name, 'Expected: Name should match');
            }catch(DmlException e){
                Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
            
            }
        Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingPaisWithoutName() {
        // Arrange
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        pais.Name = null;

        Test.startTest();
       try{
        insert pais;
        System.debug('Pais__c inserted successfully with Id: ' + pais.Id);
        
        Assert.fail('Expected: DmlException was not thrown');
       
        }catch(DmlException e){
        
            Assert.isTrue(pais.Name == null);
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem deve mencionar Name');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingPaisWithoutSigla() {
        // Arrange
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        pais.Sigla__c = null;

        Test.startTest();
       try{
        insert pais;
        System.debug('Pais__c inserted successfully with Id: ' + pais.Id);
        Assert.fail('Expected: DmlException was not thrown');
       
        }catch(DmlException e){
            Assert.isTrue(e.getMessage().contains('Sigla__c'), 'Mensagem deve mencionar Sigla__c');


       }
       Test.stopTest();
    }
}