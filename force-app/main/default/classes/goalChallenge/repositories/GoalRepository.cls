public with sharing class GoalRepository implements IGoalRepository {

    // Goal__c não possui campo de Status; o vínculo com o vendedor é Seller__c (lookup User).
    public List<Goal__c> findActiveByOwners(Set<Id> ownerIds) {
        return [
            SELECT Id, Seller__c
            FROM Goal__c
            WHERE Seller__c IN :ownerIds
        ];
    }
}
