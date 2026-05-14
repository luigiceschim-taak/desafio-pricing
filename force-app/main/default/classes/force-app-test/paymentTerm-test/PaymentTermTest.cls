@isTest
private class PaymentTermTest {

    @isTest
    static void shouldCreatePaymentTerm() {
        PaymentTerm__c pt = (PaymentTerm__c) TestFactorySObject.getInstance().createSObject(new PaymentTerm__c());

        try{
            insert pt;

            PaymentTerm__c ptInserted = [SELECT Id, Name, TermCode__c FROM PaymentTerm__c WHERE Id = :pt.Id];

            System.debug('Payment Term inserted: ' + ptInserted + ptInserted.Id);
            Assert.isNotNull(ptInserted.Id, 'Expected: Id should not be null');
            Assert.isNotNull(ptInserted.TermCode__c, 'Expected: Payment Term should be inserted');
            Assert.areEqual(pt.Name, ptInserted.Name, 'Expected: Name should match');

        } catch (DmlException e) {
            System.debug('Unexpected error: ' + e.getMessage());
            Assert.fail('Expected: DmlException was not expected');
        }
    }

    @isTest
    static void shouldFailWhenCreatingPaymentTermWithoutName() {
        PaymentTerm__c pt = (PaymentTerm__c) TestFactorySObject.getInstance().createSObject(new PaymentTerm__c());
        pt.Name = null;

        try {
            insert pt;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Expected error: ' + e.getMessage());
            Assert.isNull(pt.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Message should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
    }
}