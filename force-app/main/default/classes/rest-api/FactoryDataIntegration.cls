public with sharing class FactoryDataIntegration {
	// Conversion of the template list into the object list
	public static String convertSObject(SObject sobjectType, String service, List<DataIntegrationFields.FieldData> fieldDataList,
										List<DataIntegrationFields.Response> responseList, List<SObject> listToUpsert) {
		String orderExternalIds = '';
		String sobjectName = String.valueOf(sobjectType.getSObjectType());
		Type t = Type.forName('DataIntegrationFields.' + sobjectName.replaceAll('__c|__mdt|__|_', '') + service + 'Data');

		if (t == null) throw new FactoryDataIntegrationException('Invalid defaults class.');

		DataIntegrationFields.FieldData defaults = (DataIntegrationFields.FieldData) t.newInstance();

		for (DataIntegrationFields.FieldData obj : fieldDataList) {
			orderExternalIds += orderExternalIds == '' ? obj.getExternalId() : ', ' + obj.getExternalId();
			validateObject(defaults.getFieldId(), defaults.getFieldKey(), obj.deserialize(), listToUpsert, responseList, defaults.getRequiredFields());
		}

		return orderExternalIds;
	}

	// Object validation of required fields, adding error response and objects for upsert
	@TestVisible
	private static void validateObject(String fieldId, String fieldKey, SObject data, List<SObject> listToUpsert,
										List<DataIntegrationFields.Response> responseList, List<String> requiredField) {
		DataIntegrationFields.Response response = new DataIntegrationFields.Response();

		if (responseList instanceOf List<DataIntegrationFields.ResponseParent>)
			response = new DataIntegrationFields.ResponseParent();
		response.hasError = false;

		for (String field : requiredField) {
			if (IntegrationUtils.checkEmptyString((Object)data.get(field))) {
				if (String.isNotEmpty((String)data.get(fieldId))) {
					response.error(
						(String)data.get(fieldId),
						(String)data.get(fieldKey),
						'Valor inválido para o campo obrigatório => ' + field,
						String.valueOf(listToUpsert.getSObjectType())
					);
				}
				else {
					response.error(
						(String)data.get(fieldKey),
						'Valor inválido para o campo obrigatório => ' + field,
						String.valueOf(listToUpsert.getSObjectType())
					);
				}

				System.debug('Error Parent Object => ' + response);
				break;
			}
		}

		if (!response.hasError) listToUpsert.add(data);
		else responseList.add(response);
	}

	//Object child validation of required fields, adding error response and objects for upsert
	@TestVisible
	private static void validateObjectChild(DataIntegrationFields.FieldDataChild obj, String fieldKey, SObject data, List<SObject> listToUpsert,
											List<String> requiredField, Map<String, List<DataIntegrationFields.Response>> responseMap) {
		DataIntegrationFields.Response response = new DataIntegrationFields.Response();
		response.hasError = false;

		for (String field : requiredField) {
			if (IntegrationUtils.checkEmptyString((Object)data.get(field))) {
				response.error(
					(String)data.get(fieldKey),
					'Valor inválido para o campo obrigatório => ' + field,
					String.valueOf(listToUpsert.getSObjectType())
				);

				System.debug('Error Child Object' + response);
				break;
			}
		}

		if (!response.hasError) listToUpsert.add(data);
		else {
			if (!responseMap.containsKey(obj.getParentKey()))
				responseMap.put(obj.getParentKey(), new List<DataIntegrationFields.Response>());
			responseMap.get(obj.getParentKey()).add(response);
		}
	}

	//Conversion of the template list into the object child list
	public static void convertSObjectChild(SObject sObj, String service, List<DataIntegrationFields.FieldDataChild> fieldDataList,
											Map<String, List<DataIntegrationFields.Response>> responseMap, List<SObject> listToUpsert) {
		String sObjectName = String.valueOf(sObj.getSObjectType());
		Type classType = Type.forName('DataIntegrationFields.' + sObjectName.replaceAll('__c|__mdt|__|_', '') + service + 'Data');

		if (classType == null) throw new FactoryDataIntegrationException('Invalid defaults class.');

		DataIntegrationFields.FieldDataChild defaults = (DataIntegrationFields.FieldDataChild) classType.newInstance();

		for (DataIntegrationFields.FieldDataChild obj : fieldDataList) {
			SObject deserializedObject = obj.deserialize();
			String deserializedKey = (String)deserializedObject.get(defaults.getFieldId());
			String fieldKey = String.isNotEmpty(deserializedKey) ? defaults.getFieldId() : defaults.getFieldExternal();

			validateObjectChild(obj, fieldKey, deserializedObject, listToUpsert, defaults.getRequiredFields(), responseMap);
		}
	}

	public class FactoryDataIntegrationException extends Exception {}
}