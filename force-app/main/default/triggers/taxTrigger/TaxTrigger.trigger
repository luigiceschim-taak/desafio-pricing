trigger TaxTrigger on Tax__c (before insert, before update) {
    new TaxHandler().run();
}