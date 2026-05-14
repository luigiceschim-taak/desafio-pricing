@isTest
private class CityTest {

    @TestSetup
    static void makeData(){
        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        insert country;

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = country.Id;
        insert state;
    }

    @isTest
    static void shouldCreateCity() {
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.State__c = state.Id;

        Test.startTest();
        try{
            insert city;

            City__c actual = [SELECT Id, Name, IBGE_CODE__c, State__c FROM City__c WHERE Id = :city.Id LIMIT 1];

            System.debug('City__c inserted successfully with Id: ' + city.Id);

            Assert.isNotNull(actual.Id, 'Expected: Id should not be null');
            Assert.areEqual(city.Name, actual.Name, 'Expected: Name should match');
            Assert.areEqual(city.IBGE_CODE__c, actual.IBGE_CODE__c, 'Expected: IBGE_CODE__c should match');
            Assert.areEqual(city.State__c, actual.State__c, 'Expected: State__c should match');

            System.debug('Successfully validated inserted City__c with Id: ' + city.Id);
        }catch(DmlException e){
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCityWithoutState() {
        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.State__c = null;

        Test.startTest();
        try{
            insert city;
            System.debug('City__c inserted successfully with Id: ' + city.Id);
            Assert.fail('Should have thrown a DmlException due to missing State__c');

        }catch(DmlException e){
            Assert.isNull(city.State__c);
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCityWithoutName() {
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.Name = null;
        city.State__c = state.Id;

        Test.startTest();
        try{
            insert city;
            System.debug('City__c inserted successfully with Id: ' + city.Id);
            Assert.fail('Should have thrown a DmlException due to missing Name');
        }catch(DmlException e){
            Assert.isNull(city.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected: DmlException should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingCityWithoutIBGECode() {
        State__c state = [SELECT Id FROM State__c LIMIT 1];

        City__c city = (City__c) TestFactorySObject.getInstance().createSObject(new City__c());
        city.IBGE_CODE__c = null;
        city.State__c = state.Id;

        Test.startTest();
        try{
            insert city;
            Assert.fail('Should have thrown a DmlException due to missing IBGE_CODE__c');
        }catch(DmlException e){
            System.debug('Expected DmlException was thrown: ' + e.getMessage());
            Assert.isNull(city.IBGE_CODE__c);
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');
        }
        Test.stopTest();
    }
}