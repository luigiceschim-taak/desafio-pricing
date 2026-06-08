@isTest
private class PaymentConditionMatchingStrategyTest {

    private static OrderItem_DTO buildItem(String condition) {
        OrderItem_DTO dto = new OrderItem_DTO();
        dto.paymentCondition = condition;
        dto.amount = 75;
        return dto;
    }

    @isTest
    static void match_returnsOnlySameCondition() {
        GoalItem_DTO goalItem = new GoalItem_DTO();
        goalItem.paymentCondition = 'Boleto';

        List<OrderItem_DTO> items = new List<OrderItem_DTO>{
            buildItem('Boleto'), buildItem('Cartão'), buildItem('Boleto')
        };

        Test.startTest();
        List<OrderItem_DTO> matched = new PaymentConditionMatchingStrategy().match(items, goalItem);
        Test.stopTest();

        System.assertEquals(2, matched.size(), 'Deve casar apenas a condição alvo');
    }

    @isTest
    static void match_blankCondition_returnsEmpty() {
        GoalItem_DTO goalItem = new GoalItem_DTO();

        Test.startTest();
        List<OrderItem_DTO> matched =
            new PaymentConditionMatchingStrategy().match(new List<OrderItem_DTO>{ buildItem('Boleto') }, goalItem);
        Test.stopTest();

        System.assertEquals(0, matched.size(), 'Sem condição alvo, nada deve casar');
    }
}
