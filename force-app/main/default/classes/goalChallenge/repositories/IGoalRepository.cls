public interface IGoalRepository {
    List<Goal__c> findActiveByOwners(Set<Id> ownerIds);
}
