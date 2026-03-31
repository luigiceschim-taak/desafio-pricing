trigger FreteTrigger on Frete__c (before insert, after insert, before update, after update) {
    new freteHandler().run();
}