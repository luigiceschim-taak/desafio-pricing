public with sharing class CalloutOrder {
    private static final String NAMED_CREDENTIAL_ENDPOINT = 'callout:cred_let/services/apexrest/upsertOrder';

    public static DataIntegrationFields.CalloutResponse executeCalloutOrder(List<String> orderIdList) {
        System.debug('### [executeCalloutOrder] Início — IDs recebidos: ' + orderIdList);

        if (orderIdList.isEmpty()) {
            System.debug('### [executeCalloutOrder] Lista vazia — abortando.');
            return new DataIntegrationFields.CalloutResponse('Lista de Order Id Vazia!');
        }

        List<Order> sendOrderList = new List<Order>();
        DataIntegrationFields.CalloutResponse calloutResponse;
        HttpResponse response;
        String payload = '';

        try {
            Map<String, String> headersMap = new Map<String, String>{
                'Content-Type' => 'application/json'
            };

            sendOrderList = getOrders(orderIdList);
            System.debug('### [executeCalloutOrder] Orders encontrados na query: ' + sendOrderList.size());

            if (sendOrderList.isEmpty()) {
                System.debug('### [executeCalloutOrder] Nenhum order retornado da query — IDs podem estar inválidos ou deletados.');
                calloutResponse = new DataIntegrationFields.CalloutResponse('No Orders found for the given IDs.');
            } else {
                for (Order o : sendOrderList) {
                    System.debug('### [executeCalloutOrder] Order: Id=' + o.Id + ' | ExternalId=' + o.ExternalId__c + ' | Status=' + o.Status + ' | Items=' + o.OrderItems.size());
                }

                payload = JSON.serialize(new DataIntegrationFields.RequestList(fillOrderRequestList(sendOrderList)));
                System.debug('### [executeCalloutOrder] Payload gerado: ' + payload);
                System.debug('### [executeCalloutOrder] Endpoint: ' + NAMED_CREDENTIAL_ENDPOINT);

                response = IntegrationUtils.executeCallout(
                    NAMED_CREDENTIAL_ENDPOINT,
                    payload,
                    headersMap,
                    'POST',
                    30000);

                System.debug('### [executeCalloutOrder] Response status code: ' + response.getStatusCode());
                System.debug('### [executeCalloutOrder] Response status: ' + response.getStatus());
                System.debug('### [executeCalloutOrder] Response body: ' + response.getBody());

                calloutResponse = fillCalloutResponse(response);
                System.debug('### [executeCalloutOrder] hasError: ' + calloutResponse.hasError);
                if (calloutResponse.hasError) {
                    System.debug('### [executeCalloutOrder] errorMessage: ' + calloutResponse.errorMessage);
                }
            }
        }
        catch (Exception ex) {
            System.debug('### [executeCalloutOrder] EXCEPTION: ' + ex.getMessage());
            System.debug('### [executeCalloutOrder] Stack trace: ' + ex.getStackTraceString());
            calloutResponse = new DataIntegrationFields.CalloutResponse(ex.getMessage() + ' - ' + ex.getStackTraceString());
        }

        try {
            List<String> externalIdList = new List<String>();
            for (Order order : sendOrderList) externalIdList.add(order.ExternalId__c);

            String errorMessage = handlerError(calloutResponse);
            System.debug('### [executeCalloutOrder] Criando log de integração — externalIds: ' + externalIdList + ' | hasError: ' + calloutResponse.hasError + ' | errorMessage: ' + errorMessage);

            String integrationLogId = IntegrationLog.createLog(
                'Order',
                String.join(externalIdList, ', '),
                'Outbound',
                payload,
                response != null ? response.getBody() : '',
                errorMessage,
                NAMED_CREDENTIAL_ENDPOINT,
                calloutResponse.hasError,
                false,
                sendOrderList.isEmpty() ? null : sendOrderList[0].ExternalId__c
            );

            System.debug('### [executeCalloutOrder] Log criado com Id: ' + integrationLogId);
            updateSObjectWithIntegrationLogId(sendOrderList, integrationLogId, 'OUT');
        }
        catch (Exception ex) {
            System.debug('### [executeCalloutOrder] EXCEPTION no log: ' + ex.getMessage() + ' - ' + ex.getStackTraceString());
        }

        return calloutResponse;
    }

    @future(callout=true)
    public static void executeCalloutOrderAsync(List<String> orderIdList) {
        System.debug('### [executeCalloutOrderAsync] @future iniciado com IDs: ' + orderIdList);
        DataIntegrationFields.CalloutResponse calloutResponse = executeCalloutOrder(orderIdList);
        String newStatus = calloutResponse.hasError ? 'IntegrationError' : 'Integrated';
        updateOrderStatus(orderIdList, newStatus);
    }

    private static void updateOrderStatus(List<String> orderIdList, String newStatus) {
        List<Order> ordersToUpdate = new List<Order>();
        for (String orderId : orderIdList) {
            ordersToUpdate.add(new Order(Id = orderId, Status = newStatus));
        }
        if (!ordersToUpdate.isEmpty()) {
            TriggerControl.ignoreActivatedCheck = true;
            update ordersToUpdate;
            TriggerControl.ignoreActivatedCheck = false;
        }
    }

    public static List<Order> getOrders(List<String> orderIdList) {
        return [
            SELECT  Id, ExternalId__c, Status, EffectiveDate, Account.ExternalId__c, Pricebook2.ExternalId__c,
                    FreightType__c, Address__r.PostalCode__c, DistributionCenter__r.Name, DeliveryDate__c,
                    PaymentTerm__r.Name, Contract.ExternalId__c,
                    (
                        SELECT Id, ExternalId__c, Quantity, UnitPrice,
                               Order.ExternalId__c, Product2.ExternalId__c, PricebookEntry.ExternalId__c, ProductionCost__c
                          FROM OrderItems
                         WHERE DeletedProduct__c = false
                    )
              FROM  Order
             WHERE  Id IN :orderIdList
        ];
    }

    public static List<DataIntegrationFields.OrderParameters> fillOrderRequestList(List<Order> orderList) {
        List<DataIntegrationFields.OrderParameters> orderRequestList = new List<DataIntegrationFields.OrderParameters>();

        for (Order order : orderList) {
            orderRequestList.add(new DataIntegrationFields.OrderParameters(order));
        }

        return orderRequestList;
    }

    public static DataIntegrationFields.CalloutResponse fillCalloutResponse(HttpResponse response) {
        try {
            if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
                throw new IllegalArgumentException('Request Failed');
            }

            Boolean hasError = false;
            String responseBody = response.getBody().trim();
            List<DataIntegrationFields.ResponseParametersWrapper> responseParametersList;

            if (responseBody.startsWith('{')) {
                DataIntegrationFields.ResponseParametersWrapper singleResponse =
                    (DataIntegrationFields.ResponseParametersWrapper)JSON.deserialize(
                        responseBody, DataIntegrationFields.ResponseParametersWrapper.class
                    );
                responseParametersList = new List<DataIntegrationFields.ResponseParametersWrapper>{ singleResponse };
            } else {
                responseParametersList = (List<DataIntegrationFields.ResponseParametersWrapper>)JSON.deserialize(
                    responseBody, List<DataIntegrationFields.ResponseParametersWrapper>.class
                );
            }

            for (DataIntegrationFields.ResponseParametersWrapper responseParameter : responseParametersList) {
                if (responseParameter.hasError) hasError = true;
            }

            return new DataIntegrationFields.CalloutResponse(responseParametersList, hasError);
        }
        catch (Exception ex) {
            return new DataIntegrationFields.CalloutResponse(
                'Exception ' + response.getStatus() + '. ' + ex.getMessage() + '. \n' + response.getBody()
            );
        }
    }

    public static String handlerError(DataIntegrationFields.CalloutResponse calloutResponse) {
        if (!calloutResponse.hasError) return '';

        String errorMessage = '';

        if (calloutResponse.parsedResponses != null) {
            for (DataIntegrationFields.ResponseParametersWrapper response : calloutResponse.parsedResponses) {
                if (response.hasError) {
                    errorMessage += (response.externalId != null ? response.externalId + ' => ' : '') + response.errorMessage + '\n';
                }

                if (response.items != null) {
                    for (DataIntegrationFields.ResponseParametersWrapper item : response.items) {
                        if (item.hasError) {
                            errorMessage += (item.externalId != null ? item.externalId + ' => ' : '') + item.errorMessage + '\n';
                        }
                    }
                }
            }
        }
        else errorMessage = calloutResponse.errorMessage;

        return errorMessage;
    }

    public static void updateSObjectWithIntegrationLogId(List<SObject> sobjectList, String integrationLogId, String integrationType) {
        if (sobjectList.isEmpty()) return;

        List<SObject> sobjectUpdateList = new List<SObject>();
        String sobjectName = sobjectList[0].getSObjectType().getDescribe().getName();

        String query = 'SELECT Id, IntegrationLogInbound__c, IntegrationLogOutbound__c FROM ' + sobjectName + ' WHERE Id IN: sobjectList';

        for (SObject sobj : Database.query(query)) {
            if (integrationType == 'IN') sobj.put('IntegrationLogInbound__c', integrationLogId);
            else sobj.put('IntegrationLogOutbound__c', integrationLogId);

            sobjectUpdateList.add(sobj);
        }

        if (!sobjectUpdateList.isEmpty()) {
            TriggerControl.ignoreActivatedCheck = true;
            update sobjectUpdateList;
            TriggerControl.ignoreActivatedCheck = false;
        }
    }
}
