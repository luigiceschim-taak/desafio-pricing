@isTest
private class DistributionCenterTest {

    @isTest
    static void shouldCreateDistributionCenter() {
        DistributionCenter__c dc = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());

        try{
            insert dc;

            DistributionCenter__c inserted = [SELECT Id, Name, Code__c FROM DistributionCenter__c WHERE Id = :dc.Id];

            System.debug('Distribution Center inserted: ' + inserted + inserted.Id + inserted.Code__c);
            Assert.isNotNull(inserted.Code__c, 'Expected: Distribution Center should be inserted');
            Assert.isNotNull(inserted.Id, 'Expected: Id should not be null');
            Assert.areEqual(dc.Name, inserted.Name, 'Expected: Name should match the default value');

        } catch (DmlException e) {
            System.debug('Unexpected error: ' + e.getMessage());
            Assert.fail('Expected: DmlException was not expected');
        }
    }

    @isTest
    static void shouldFailWhenCreatingDistributionCenterWithoutName() {
        DistributionCenter__c dc = (DistributionCenter__c) TestFactorySObject.getInstance().createSObject(new DistributionCenter__c());
        dc.Name = null;

        try {
            insert dc;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Expected error: ' + e.getMessage());
            Assert.isNull(dc.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Message should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
    }
}