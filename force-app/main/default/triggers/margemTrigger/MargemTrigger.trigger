trigger MargemTrigger on Margem__c (before insert, before update) {
    new MargemHandler().run();
    }

