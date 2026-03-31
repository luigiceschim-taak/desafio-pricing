trigger ImpostoTrigger on Imposto__c (before insert, after insert, before update, after update) {
    new ImpostoHandler().run();

}