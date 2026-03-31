trigger MargemTrigger on Margem__c (before insert, after insert, before update, after update) {
    new MargemHandler().run();
    }

