@IsTest
public with sharing class IntegrationUtilsTest {
	@TestSetup
	public static void makeData(){
		TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();

		Account newAccount = (Account)sobjectFactory.createSObject(new Account(Name = 'Name Test'));
		insert newAccount;
	}

	@IsTest
	public static void upsertRecordsTest() {
		List<DataIntegrationFields.ResponseParent> responseList = new List<DataIntegrationFields.ResponseParent>();
		List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name = 'Name Test'];
		Account newAccountError = new Account(Name = '');

		Test.startTest();
			IntegrationUtils.checkEmptyString('');
			IntegrationUtils.upsertRecords(Database.upsert(accountList, Account.Id, false), responseList, accountList, Account.Name);
			IntegrationUtils.upsertRecords(Database.upsert(new List<Account>{ newAccountError }, Account.Id, false), responseList, accountList, Account.Name);
		Test.stopTest();
	}

	@IsTest
	public static void upsertChildRecordsTest() {
		Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
		List<Account> accountList = [SELECT Id, Name FROM Account WHERE Name = 'Name Test'];
		Map<String, String> accountMap = new Map<String, String>{ accountList[0].Name => accountList[0].Name };
		List<Account> accountErrorList = new List<Account>{ new Account(Name = '') };

		Test.startTest();
			IntegrationUtils.upsertChildRecords(Database.upsert(accountList, Account.Id, false), responseMap, accountList, accountMap, Account.Name);
			IntegrationUtils.upsertChildRecords(Database.upsert(accountErrorList, Account.Id, false), responseMap, accountList, accountMap, Account.Name);
		Test.stopTest();
	}
}