@isTest
private class AddressTest {

    @TestSetup
    static void makeData(){
        AccountGroup__c accountGroup = (AccountGroup__c) TestFactorySObject.getInstance().createSObject(new AccountGroup__c());
        insert accountGroup;

        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.AccountGroup__c = accountGroup.Id;
        insert account;

        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        insert country;

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = country.Id;
        insert state;

        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.State__c = state.Id;
        insert city;
    }

    @isTest
    static void shouldCreateAddress() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        City__c city = [SELECT Id FROM City__c LIMIT 1];

        Address__c address = (Address__c) TestFactorySObject.getInstance().createSObject(new Address__c());
        address.Account__c = account.Id;
        address.City__c = city.Id;

        try{
            insert address;

            Address__c inserted = [SELECT Id, Name, Street__c, Neighborhood__c, PostalCode__c, Account__c, City__c FROM Address__c WHERE Id = :address.Id];

            System.debug('Address inserted: ' + inserted + inserted.Id);
            Assert.isNotNull(inserted.Id, 'Expected: Id should not be null');

            Assert.areEqual(address.Account__c, inserted.Account__c, 'Expected: Account should match');
            Assert.areEqual(address.City__c, inserted.City__c, 'Expected: City should match');
            Assert.areEqual(address.Name, inserted.Name, 'Expected: Name should match');
            Assert.areEqual(address.Street__c, inserted.Street__c, 'Expected: Street should match');
            Assert.areEqual(address.Neighborhood__c, inserted.Neighborhood__c, 'Expected: Neighborhood should match');
            Assert.areEqual(address.PostalCode__c, inserted.PostalCode__c, 'Expected: PostalCode should match');

        } catch (DmlException e) {
            System.debug('Unexpected error: ' + e.getMessage());
            Assert.fail('Expected: DmlException was not expected');
        }
    }

    @isTest
    static void shouldNotCreateAddressWithoutName() {
        City__c city = [SELECT Id FROM City__c LIMIT 1];
        Account account = [SELECT Id FROM Account LIMIT 1];

        Address__c address = (Address__c) TestFactorySObject.getInstance().createSObject(new Address__c());
        address.Name = null;
        address.City__c = city.Id;
        address.Account__c = account.Id;

        try{
            insert address;
            Assert.fail('Expected: DmlException was expected due to missing Name');
        } catch (DmlException e) {
            System.debug('Expected error: ' + e.getMessage());
            Assert.isNull(address.Name);
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected: DmlException should indicate FIELD_CUSTOM_VALIDATION_EXCEPTION');
        }
    }
}