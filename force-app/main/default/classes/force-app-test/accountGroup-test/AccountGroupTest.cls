@isTest
private class AccountGroupTest {

    @isTest
    static void shouldCreateAccountGroup() {
        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());

        Test.startTest();
        try {
            insert accountGroup;
            System.debug('AccountGroup__c inserted successfully with Id: ' + accountGroup.Id);

            AccountGroup__c actual = [SELECT Id, Name FROM AccountGroup__c WHERE Id = :accountGroup.Id LIMIT 1];

            Assert.areEqual(accountGroup.Id, actual.Id, 'Expected: Id should match');
            Assert.areEqual(accountGroup.Name, actual.Name, 'Expected: Name should match');
        }catch(DmlException e){
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenAccountGroupWillBeCreatedWithoutName() {
        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        accountGroup.Name = null;

        Test.startTest();
        try {
            insert accountGroup;
            Assert.fail('Error: account group inserted in test without name');
        }catch (DmlException e) {
            System.debug('Expected error: ' + e.getMessage());
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Message should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
        Test.stopTest();
    }
}