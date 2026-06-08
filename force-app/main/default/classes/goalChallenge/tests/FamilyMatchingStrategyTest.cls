@isTest
private class FamilyMatchingStrategyTest {

    private static OrderItem_DTO buildItem(String family) {
        OrderItem_DTO dto = new OrderItem_DTO();
        dto.productFamily = family;
        dto.amount = 50;
        return dto;
    }

    @isTest
    static void match_returnsOnlySameFamily() {
        GoalItem_DTO goalItem = new GoalItem_DTO();
        goalItem.productFamily = 'Hardware';

        List<OrderItem_DTO> items = new List<OrderItem_DTO>{
            buildItem('Hardware'), buildItem('SaaS'), buildItem('Hardware'), buildItem(null)
        };

        Test.startTest();
        List<OrderItem_DTO> matched = new FamilyMatchingStrategy().match(items, goalItem);
        Test.stopTest();

        System.assertEquals(2, matched.size(), 'Deve casar apenas a família alvo');
    }

    @isTest
    static void match_blankFamily_returnsEmpty() {
        GoalItem_DTO goalItem = new GoalItem_DTO();

        Test.startTest();
        List<OrderItem_DTO> matched =
            new FamilyMatchingStrategy().match(new List<OrderItem_DTO>{ buildItem('SaaS') }, goalItem);
        Test.stopTest();

        System.assertEquals(0, matched.size(), 'Sem família alvo, nada deve casar');
    }
}
