public with sharing class FamilyMatchingStrategy implements IGoalMatchingStrategy {

    public List<OrderItem_DTO> match(List<OrderItem_DTO> orderItems, GoalItem_DTO goalItem) {
        List<OrderItem_DTO> matched = new List<OrderItem_DTO>();
        if (String.isBlank(goalItem.productFamily)) return matched;

        for (OrderItem_DTO item : orderItems) {
            if (goalItem.productFamily.equals(item.productFamily)) {
                matched.add(item);
            }
        }
        return matched;
    }
}
