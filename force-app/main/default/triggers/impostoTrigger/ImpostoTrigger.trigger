trigger ImpostoTrigger on Imposto__c (before insert, before update) {
    new ImpostoHandler().run();

}