public with sharing class PaymentConditionMatchingStrategy implements IGoalMatchingStrategy {

    public List<OrderItem_DTO> match(List<OrderItem_DTO> orderItems, GoalItem_DTO goalItem) {
        List<OrderItem_DTO> matched = new List<OrderItem_DTO>();
        if (String.isBlank(goalItem.paymentCondition)) return matched;

        for (OrderItem_DTO item : orderItems) {
            if (goalItem.paymentCondition.equals(item.paymentCondition)) {
                matched.add(item);
            }
        }
        return matched;
    }
}
