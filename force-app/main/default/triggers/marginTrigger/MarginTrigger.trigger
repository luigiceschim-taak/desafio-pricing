trigger MarginTrigger on Margin__c (before insert, before update) {
    new MarginHandler().run();
}