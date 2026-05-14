@isTest
private class AccountTest {

    @TestSetup
    static void makeData(){
        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        insert accountGroup;
    }

    @isTest
    static void shouldFailWhenAccountWillBeCreatedWithInvalidCNPJ() {
        AccountGroup__c accountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];

        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.AccountGroup__c = accountGroup.Id;
        acc.CNPJ__c = '00000000000001';

        try {
            insert acc;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Expected error: ' + e.getMessage());
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Message should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
    }

    @isTest
    static void shouldFailWhenAccountWillBeCreatedWithoutAccountGroup() {
        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.AccountGroup__c = null;

        try {
            insert acc;
            Assert.fail('Expected: DmlException was not thrown');
        } catch (DmlException e) {
            System.debug('Expected error: ' + e.getMessage());
            Assert.isNull(acc.AccountGroup__c);
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Message should mention REQUIRED_FIELD_MISSING');
        }
    }

    @isTest
    static void shouldCreateAccountWithAccountGroupCNPJName() {
        AccountGroup__c accountGroup = [SELECT Id FROM AccountGroup__c LIMIT 1];

        Account acc = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        acc.AccountGroup__c = accountGroup.Id;

        try{
            insert acc;
            System.debug('Account inserted successfully with Id: ' + acc.Id);

            Account actual = [SELECT Id, Name, CNPJ__c, AccountGroup__c FROM Account WHERE Id = :acc.Id LIMIT 1];

            Assert.isNotNull(actual.Id, 'Expected: Id should not be null');
            Assert.areEqual(acc.Name, actual.Name, 'Expected: Name should match');
            Assert.areEqual(acc.CNPJ__c, actual.CNPJ__c, 'Expected: CNPJ__c should match');
            Assert.areEqual(acc.AccountGroup__c, actual.AccountGroup__c, 'Expected: AccountGroup__c should match');

            System.debug('Successfully validated inserted Account with Id: ' + acc.Id);

        }catch(DmlException e){
            System.debug('Unexpected DmlException was thrown: ' + e.getMessage());
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
        }
    }
}