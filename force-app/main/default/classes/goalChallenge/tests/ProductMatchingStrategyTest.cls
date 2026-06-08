@isTest
private class ProductMatchingStrategyTest {

    private static OrderItem_DTO buildItem(Id productId) {
        OrderItem_DTO dto = new OrderItem_DTO();
        dto.productId = productId;
        dto.amount = 100;
        return dto;
    }

    @isTest
    static void match_returnsOnlySameProduct() {
        Id target = TestIdFactory.product();
        Id other = TestIdFactory.product();

        GoalItem_DTO goalItem = new GoalItem_DTO();
        goalItem.productId = target;

        List<OrderItem_DTO> items = new List<OrderItem_DTO>{
            buildItem(target), buildItem(other), buildItem(target)
        };

        Test.startTest();
        List<OrderItem_DTO> matched = new ProductMatchingStrategy().match(items, goalItem);
        Test.stopTest();

        System.assertEquals(2, matched.size(), 'Deve retornar apenas os itens do produto alvo');
        for (OrderItem_DTO m : matched) {
            System.assertEquals(target, m.productId, 'Item retornado deve ser do produto alvo');
        }
    }

    @isTest
    static void match_nullProduct_returnsEmpty() {
        GoalItem_DTO goalItem = new GoalItem_DTO();

        Test.startTest();
        List<OrderItem_DTO> matched =
            new ProductMatchingStrategy().match(new List<OrderItem_DTO>{ buildItem(TestIdFactory.product()) }, goalItem);
        Test.stopTest();

        System.assertEquals(0, matched.size(), 'Sem produto alvo, nada deve casar');
    }
}
