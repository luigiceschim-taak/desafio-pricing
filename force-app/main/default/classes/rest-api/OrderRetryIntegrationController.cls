public with sharing class OrderRetryIntegrationController {

    @AuraEnabled
    public static void retryIntegration(Id orderId) {
        CalloutOrder.executeCalloutOrderAsync(new List<String>{ orderId });
    }
}