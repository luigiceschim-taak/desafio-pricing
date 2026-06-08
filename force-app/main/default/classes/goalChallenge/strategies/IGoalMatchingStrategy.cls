public interface IGoalMatchingStrategy {
    List<OrderItem_DTO> match(List<OrderItem_DTO> orderItems, GoalItem_DTO goalItem);
}
