@isTest
private class TaxTriggerHandlerTest {
    @isTest
    static void coverBaseMethods() {
        TaxTriggerHandler handler = new TaxTriggerHandler();
        handler.beforeInsert();
        handler.beforeUpdate();
    }
}