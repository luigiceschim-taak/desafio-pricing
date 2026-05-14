trigger FreightTrigger on Freight__c (before insert, before update) {
    new FreightHandler().run();
}