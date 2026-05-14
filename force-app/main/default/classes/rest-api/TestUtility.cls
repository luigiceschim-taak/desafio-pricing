public with sharing class TestUtility {
	public static String getBody() {
		String body = '{ "orderRequestList": [ { ' +
			'"externalId": "9999",' +
			'"status": "Draft",' +
			'"effectiveDate": "2030-07-21",' +
			'"accountExternalId": "6",' +
			'"pricebook2ExternalId": "STANDARD PRICEBOOK",' +
			'"orderItemList": [' +
			'	{' +
			'		"externalId": "9991",' +
			'		"quantity": 111,' +
			'		"unitPrice": 111.00,' +
			'		"orderExternalId": "9999",' +
			'		"productExternalId": "16",' +
			'		"pricebookEntryExternalId": "32"' +
			'	}' +
			']' +
		'} ] }';

		return body;
	}

	public static String getBodyResponse() {
		String body = '[ { ' +
			'"hasError": false,' +
			'"errorMessage": "",' +
			'"salesforceId": "0123456789",' +
			'"externalId": "CalloutOrder",' +
			'"sobjectType": "Orderd"' +
		' }, { ' +
			'"hasError": true,' +
			'"errorMessage": "",' +
			'"salesforceId": "0123456789",' +
			'"externalId": "CalloutOrderError",' +
			'"sobjectType": "Orderd"' +
		' } ]';

		return body;
	}

	public static String getBodyResponseError() {
		return '{}';
	}

	public static String getBodyAccessToken() {
		return '{ "access_token": "ClassTest" }';
	}
}