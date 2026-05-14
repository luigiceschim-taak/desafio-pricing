@isTest
private class CountryTest {

    @isTest
    static void shouldCreateCountry() {
        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());

        Test.startTest();
        try{
            insert country;
            System.debug('Country__c inserted successfully with Id: ' + country.Id);

            Country__c actual = [SELECT Id, Code__c, Name FROM Country__c WHERE Id = :country.Id LIMIT 1];

            Assert.areEqual(country.Id, actual.Id, 'Expected: Id should match');
            Assert.areEqual(country.Code__c, actual.Code__c, 'Expected: Code__c should match');
            Assert.areEqual(country.Name, actual.Name, 'Expected: Name should match');
        }catch(DmlException e){
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCountryWithoutName() {
        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        country.Name = null;

        Test.startTest();
        try{
            insert country;
            System.debug('Country__c inserted successfully with Id: ' + country.Id);
            Assert.fail('Expected: DmlException was not thrown');

        }catch(DmlException e){
            Assert.isTrue(country.Name == null);
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Message should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCountryWithoutCode() {
        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        country.Code__c = null;

        Test.startTest();
        try{
            insert country;
            System.debug('Country__c inserted successfully with Id: ' + country.Id);
            Assert.fail('Expected: DmlException was not thrown');

        }catch(DmlException e){
            Assert.isTrue(e.getMessage().contains('Code__c'), 'Message should mention Code__c');
       }
       Test.stopTest();
    }
}