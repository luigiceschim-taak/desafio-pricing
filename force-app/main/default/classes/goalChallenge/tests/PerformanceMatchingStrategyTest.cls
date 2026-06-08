@isTest
private class PerformanceMatchingStrategyTest {

    @isTest
    static void match_returnsAllItems() {
        GoalItem_DTO goalItem = new GoalItem_DTO();

        List<OrderItem_DTO> items = new List<OrderItem_DTO>();
        for (Integer i = 0; i < 3; i++) {
            OrderItem_DTO dto = new OrderItem_DTO();
            dto.amount = 10 * i;
            items.add(dto);
        }

        Test.startTest();
        List<OrderItem_DTO> matched = new PerformanceMatchingStrategy().match(items, goalItem);
        Test.stopTest();

        System.assertEquals(3, matched.size(), 'Performance deve retornar todos os itens');
    }

    @isTest
    static void match_emptyInput_returnsEmpty() {
        Test.startTest();
        List<OrderItem_DTO> matched =
            new PerformanceMatchingStrategy().match(new List<OrderItem_DTO>(), new GoalItem_DTO());
        Test.stopTest();

        System.assertEquals(0, matched.size(), 'Sem itens, retorna lista vazia');
    }
}
