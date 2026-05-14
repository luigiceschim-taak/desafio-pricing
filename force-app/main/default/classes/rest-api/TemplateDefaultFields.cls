public with sharing class TemplateDefaultFields {
	public interface FieldDefaults {
		Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
	}

	public class UserDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'ExternalId__c' => '10' + countSObjectCreated,
				'Username' => 'test' + Datetime.now().getTime() +'@test.com',
				'LastName' => 'inquima',
				'Email' => 'inquima@inquima.com',
				'Alias' => 'inquima',
				'CommunityNickname' => 'inquima',
				'TimeZoneSidKey' => 'America/Sao_Paulo',
				'LocaleSidKey' => 'pt_BR',
				'EmailEncodingKey' => 'ISO-8859-1',
				'LanguageLocaleKey' => 'pt_BR'
			};
		}
	}

	public class AccountDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Account - Teste'
			};
		}
	}

	public class Product2Defaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'TA35',
				'ExternalId__c' => 'Product2' + countSObjectCreated
			};
		}
	}

	public class Pricebook2Defaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'Pricebook2 - Teste',
				'ExternalId__c' => 'Pricebook2' + countSObjectCreated
			};
		}
	}

	public class PricebookEntryDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'UnitPrice' => 100,
				'ExternalId__c' => 'PricebookEntry' + countSObjectCreated
			};
		}
	}

	public class OrderDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'EffectiveDate' => Date.today().addDays(2),
				'Status' => 'Draft',
				'ExternalId__c' => 'OrderExternalId' + countSObjectCreated
			};
		}
	}

	public class OrderItemDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Quantity' => 10,
				'UnitPrice' => 100.00,
				'ExternalId__c' => 'OrderItemExternalId' + countSObjectCreated
			};
		}
	}

	public class IntegrationSettingDefaults implements FieldDefaults {
		public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
			return new Map<String, Object>{
				'Name' => 'IntegrationSettingName',
				'Method__c' => 'POST',
				'Endpoint__c' => 'Endpoint',
				'User__c' => UserInfo.getUserName(),
				'Password__c' => UserInfo.getUserName(),
				'Timeout__c' => 110000,
				'AccessToken__c' => 'AccessToken' + String.valueOf(Datetime.now()),
				'ClientId__c' => String.valueOf(Datetime.now()),
				'ClientSecret__c' => UserInfo.getUserName() + String.valueOf(Datetime.now()),
				'EndpointAccessToken__c' => 'EndpointAccessToken',
				'AccessTokenTime__c' => 360000,
				'LastAccessTokenTime__c' => Decimal.valueOf(Datetime.now().getTime())
			};
		}
	}
}