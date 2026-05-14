@isTest
private class StateTest {

    @TestSetup
    static void makeData(){
        Country__c country = (Country__c) TestFactorySObject.getInstance().createSObject(new Country__c());
        insert country;
    }

    @isTest
    static void shouldCreateState() {
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = country.Id;

        Test.startTest();
        try{
            insert state;

            State__c actual = [SELECT Id, Name, Code__c, Country__c FROM State__c WHERE Id = :state.Id LIMIT 1];

            System.debug('State__c inserted successfully with Id: ' + state.Id);

            Assert.isNotNull(actual.Id, 'Expected: Id should not be null');
            Assert.areEqual(state.Name, actual.Name, 'Expected: Name should match');
            Assert.areEqual(state.Code__c, actual.Code__c, 'Expected: Code__c should match');
            Assert.areEqual(state.Country__c, actual.Country__c, 'Expected: Country__c should match');

            System.debug('Successfully validated inserted State__c with Id: ' + state.Id);

        }catch(DmlException e){
            Assert.fail('Unexpected DmlException was thrown: ' + e.getMessage());
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingStateWithoutCountry() {
        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = null;

        Test.startTest();
        try{
            insert state;
            System.debug('State__c inserted successfully with Id: ' + state.Id);
            Assert.fail('Expected: DmlException was not thrown');

        }catch(DmlException e){
            Assert.isNull(state.Country__c, 'Expected: Country__c should be null');
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingStateWithoutName() {
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Name = null;
        state.Country__c = country.Id;

        Test.startTest();
        try{
            insert state;
            System.debug('State__c inserted successfully with Id: ' + state.Id);
            Assert.fail('Expected: DmlException was not thrown');
        }catch(DmlException e){
            Assert.isNull(state.Name, 'Expected: Name should be null');
            Assert.isTrue(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected: DmlException should mention FIELD_CUSTOM_VALIDATION_EXCEPTION');
       }
       Test.stopTest();
    }

    @isTest
    static void shouldFailWhenCreatingStateWithoutCode() {
        Country__c country = [SELECT Id FROM Country__c LIMIT 1];

        State__c state = (State__c) TestFactorySObject.getInstance().createSObject(new State__c());
        state.Country__c = country.Id;
        state.Code__c = null;

        Test.startTest();
        try{
            insert state;
            System.debug('State__c inserted successfully with Id: ' + state.Id);
            Assert.fail('Expected: DmlException was not thrown');
        }catch(DmlException e){
            Assert.isNull(state.Code__c, 'Expected: Code__c should be null');
            Assert.isTrue(e.getMessage().contains('REQUIRED_FIELD_MISSING'), 'Expected: DmlException should mention REQUIRED_FIELD_MISSING');
       }
       Test.stopTest();
    }
}