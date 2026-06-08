public with sharing class PerformanceMatchingStrategy implements IGoalMatchingStrategy {

    // Meta de performance: agrega todos os itens do vendedor, sem filtro de critério.
    public List<OrderItem_DTO> match(List<OrderItem_DTO> orderItems, GoalItem_DTO goalItem) {
        return new List<OrderItem_DTO>(orderItems);
    }
}
