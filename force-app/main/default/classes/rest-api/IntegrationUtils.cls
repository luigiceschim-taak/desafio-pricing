public with sharing class IntegrationUtils {
	public static Boolean checkEmptyString(Object value) {
		return ((value == null || value == '' || value == 'null') ? true : false);
	}

	// Records upsert validation, adding results to the response list
	public static Boolean upsertRecords(List<Database.UpsertResult> upsertResults, List<DataIntegrationFields.ResponseParent> responseList,
										List<SObject> sobjectListToUpsert, Schema.SObjectField field) {
		Boolean hasError = false;
		for (DataIntegrationFields.Response response : responseList) hasError = response.hasError;

		for (Integer i = 0; i < upsertResults.size(); i++) {
			DataIntegrationFields.ResponseParent responseData = new DataIntegrationFields.ResponseParent();
			SObject sobjectResult = sobjectListToUpsert[i];
			Database.UpsertResult upsertResult = upsertResults[i];

			if (upsertResult.isSuccess()) {
				responseData.success(
					upsertResult.getId(),
					String.valueOf(sobjectResult.get(field)),
					String.valueOf(sobjectResult.getSObjectType())
				);
			}
			else {
				responseData.error(
					String.valueOf(sobjectResult.get(field)),
					upsertResult.getErrors()[0].getMessage().replace('Campos obrigatórios ausentes', 'Valor inválido para o campo obrigatório'),
					String.valueOf(sobjectResult.getSObjectType())
				);

				hasError = true;
			}

			responseList.add(responseData);
		}

		return hasError;
	}

	// Child records upsert validation, adding results to the response list
	public static void upsertChildRecords(List<Database.UpsertResult> upsertResults, Map<String, List<DataIntegrationFields.Response>> responseMap,
											List<SObject> sobjectListToUpsert, Map<String, String> parentExternalIdToChild, Schema.SObjectField field) {
		for (Integer i = 0; i < upsertResults.size(); i++) {
			DataIntegrationFields.Response responseData = new DataIntegrationFields.Response();
			SObject objectResult = sobjectListToUpsert[i];
			Database.UpsertResult upsertResult = upsertResults[i];

			if (upsertResult.isSuccess()) {
				responseData.success(
					upsertResult.getId(),
					String.valueOf(objectResult.get(field)),
					String.valueOf(objectResult.getSObjectType())
				);
			}
			else {
				responseData.error(
					String.valueOf(objectResult.get(field)),
					upsertResult.getErrors()[0].getMessage().replace('Campos obrigatórios ausentes', 'Valor inválido para o campo obrigatório'),
					String.valueOf(objectResult.getSObjectType())
				);
			}

			String responseKey = parentExternalIdToChild.get((String)objectResult.get(field));
			// Associating child object's response with object response
			if (!responseMap.containsKey(responseKey))
				responseMap.put(responseKey, new List<DataIntegrationFields.Response>());
			responseMap.get(responseKey).add(responseData);
		}
	}
}