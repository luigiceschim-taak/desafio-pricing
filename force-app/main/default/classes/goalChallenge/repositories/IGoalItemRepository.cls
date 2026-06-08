public interface IGoalItemRepository {
    List<GoalItem_DTO> findByGoals(Set<Id> goalIds);
}
