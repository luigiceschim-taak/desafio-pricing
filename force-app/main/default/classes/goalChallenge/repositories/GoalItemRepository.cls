public with sharing class GoalItemRepository implements IGoalItemRepository {

    public List<GoalItem_DTO> findByGoals(Set<Id> goalIds) {
        List<GoalItem_DTO> result = new List<GoalItem_DTO>();

        for (GoalItem__c gi : [
                SELECT Id, Goal__c, RecordType.DeveloperName,
                       Goal_Product__c, Product_Family__r.Name, Goal_Condition_Payment__r.Name,
                       Goal_Amount__c, Projected_Amount__c, Negotiated_Value__c, Realized_Value__c
                FROM GoalItem__c
                WHERE Goal__c IN :goalIds
        ]) {
            GoalItem_DTO dto = new GoalItem_DTO();
            dto.id = gi.Id;
            dto.goalId = gi.Goal__c;
            dto.recordTypeDeveloperName = gi.RecordType.DeveloperName;
            dto.productId = gi.Goal_Product__c;
            dto.productFamily = gi.Product_Family__r.Name;
            dto.paymentCondition = gi.Goal_Condition_Payment__r.Name;
            dto.target = gi.Goal_Amount__c;
            dto.projected = gi.Projected_Amount__c;
            dto.negotiated = gi.Negotiated_Value__c;
            dto.realized = gi.Realized_Value__c;
            result.add(dto);
        }
        return result;
    }
}
