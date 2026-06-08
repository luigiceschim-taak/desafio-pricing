public with sharing class ProductMatchingStrategy implements IGoalMatchingStrategy {

    public List<OrderItem_DTO> match(List<OrderItem_DTO> orderItems, GoalItem_DTO goalItem) {
        List<OrderItem_DTO> matched = new List<OrderItem_DTO>();
        if (goalItem.productId == null) return matched;

        for (OrderItem_DTO item : orderItems) {
            if (item.productId == goalItem.productId) {
                matched.add(item);
            }
        }
        return matched;
    }
}
