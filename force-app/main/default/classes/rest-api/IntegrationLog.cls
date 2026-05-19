public with sharing class IntegrationLog {
	public static Id createLog(String integrationName, String externalIdList, String recordTypeName, String payloadIN, String payloadOUT, String errorMessage,
								String endpoint, Boolean hasAnyErrors, Boolean hasDeleted, String orderExternalId){
		System.debug('');
		// Se os dados forem maiores que 100.000 TRUE, se não FALSE
		Boolean attachmentIN = (payloadIN.length() > 130000);
		Boolean attachmentOUT = (payloadOUT.length() > 130000);
		Datetime datetimeNow = System.now(); // Data Atual
		// Pega Id do log de integração (IN ou OUT)
		Map<String, Schema.RecordTypeInfo> rtByDevName = Schema.SObjectType.IntegrationLog__c.getRecordTypeInfosByDeveloperName();
		Id recordTypeId = rtByDevName.containsKey(recordTypeName) ? rtByDevName.get(recordTypeName).getRecordTypeId() : null;

		if (recordTypeId == null) System.debug('Falha ao pegar o recordTypeId do log de integração => ' + recordTypeId);

		IntegrationLog__c log = createIntegrationLogRecord(
			integrationName, externalIdList, recordTypeId, recordTypeName, attachmentIN, attachmentOUT, payloadIN, payloadOUT,
			endpoint, hasAnyErrors, datetimeNow, hasDeleted, orderExternalId
		);

		try { // Insere o log de integração e cria anexo se for necessario
			insert log;

			// Confere se é necessario criar anexo
			if (attachmentIN) createAttachment(log.Id, integrationName, 'IN', log.Name, String.valueOf(datetimeNow), payloadIN);
			if (attachmentOUT) createAttachment(log.Id, integrationName, 'OUT', log.Name, String.valueOf(datetimeNow), payloadOUT);
		}
		catch (Exception error) {
			System.debug('EXCEPTION ON LOG - Please review parameters - ' + error.getMessage() + ' - ' + error.getStackTraceString());
			log.Status__c = 'Error';
			log.ErrorMessage__c = error.getMessage();
		}

		return log.Id;
	}

	public static IntegrationLog__c createIntegrationLogRecord(String integrationName, String externalIdList, Id recordTypeId,
									String recordTypeName, Boolean attachmentIN, Boolean attachmentOUT, String payloadIN,
									String payloadOUT, String endpoint, Boolean hasAnyErrors, Datetime datetimeNow, Boolean hasDeleted,  String orderExternalId) {
		return new IntegrationLog__c(
			Name = integrationName + ' ' + recordTypeName,
			Endpoint__c = endpoint,
			ExternalIdList__c = externalIdList.length() > 255 ? externalIdList.substring(0, 256) : externalIdList,
			RecordTypeId = recordTypeId,
			Attachment__c = (attachmentIN || attachmentOUT),
			PayloadIN__c = (attachmentIN  ? '' : payloadIN),
			PayloadOUT__c = (attachmentOUT ? '' : payloadOUT),
			ExecutionDate__c = datetimeNow,
			Status__c = (hasAnyErrors ? 'Error' : 'Success'),
			ErrorMessage__c = '',
			HasDeleted__c = hasDeleted,
			Order__r =  new Order(ExternalId__c = orderExternalId) 
		);
	}

	@TestVisible
	private static Id createAttachment(String recordId, String integrationName, String inOrOut, String logName, String timeAsString, String payload){
		Attachment attachment = new Attachment(
			Name = 'LOG-' + integrationName + '-' + inOrOut + '-' + timeAsString + '.txt',
			Body = Blob.valueOf(payload),
			ParentId = recordId
		);

		insert attachment;

		return attachment.Id;
	}
}