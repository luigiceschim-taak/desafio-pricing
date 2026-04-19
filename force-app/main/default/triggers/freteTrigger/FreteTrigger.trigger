trigger FreteTrigger on Frete__c (before insert, before update) {
    new freteHandler().run();
}