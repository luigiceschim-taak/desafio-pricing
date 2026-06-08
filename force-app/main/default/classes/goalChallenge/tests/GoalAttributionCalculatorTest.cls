@isTest
private class GoalAttributionCalculatorTest {

    private static OrderItem_DTO item(String status, Decimal amount) {
        OrderItem_DTO dto = new OrderItem_DTO();
        dto.orderStatus = status;
        dto.amount = amount;
        return dto;
    }

    @isTest
    static void calculate_bucketsByStatus() {
        Id goalItemId = TestIdFactory.goalItem();
        MatchResult match = new MatchResult(goalItemId);
        match.matchedItems = new List<OrderItem_DTO>{
            item('New', 100),
            item('New', 50),
            item('PendingApproval', 200),
            item('Approved', 300),
            item('Integrated', 25),          // realizado permanente (pós-aprovação)
            item('IntegrationError', 5),     // realizado permanente (pós-aprovação)
            item(null, 999)                  // status nulo é ignorado
        };

        Test.startTest();
        Map<Id, GoalItem_DTO> result =
            new GoalAttributionCalculator().calculate(new List<MatchResult>{ match });
        Test.stopTest();

        GoalItem_DTO dto = result.get(goalItemId);
        // Projected = New (100+50) + PendingApproval (200)
        System.assertEquals(350, dto.projected, 'Projected = New + PendingApproval');
        System.assertEquals(200, dto.negotiated, 'Negotiated = PendingApproval');
        // Realized = Approved (300) + Integrated (25) + IntegrationError (5): conjunto permanente pós-aprovação
        System.assertEquals(330, dto.realized, 'Realized = Approved + Integrated + IntegrationError');
    }

    @isTest
    static void calculate_noMatches_returnsZeros() {
        Id goalItemId = TestIdFactory.goalItem();
        MatchResult match = new MatchResult(goalItemId);

        Test.startTest();
        Map<Id, GoalItem_DTO> result =
            new GoalAttributionCalculator().calculate(new List<MatchResult>{ match });
        Test.stopTest();

        GoalItem_DTO dto = result.get(goalItemId);
        System.assertEquals(0, dto.projected, 'Sem itens, projected zerado');
        System.assertEquals(0, dto.negotiated, 'Sem itens, negotiated zerado');
        System.assertEquals(0, dto.realized, 'Sem itens, realized zerado');
    }
}
