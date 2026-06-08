@isTest
private class GoalMatchingStrategyFactoryTest {

    @isTest
    static void getStrategy_returnsConfiguredImplementations() {
        Test.startTest();
        GoalMatchingStrategyFactory factory = new GoalMatchingStrategyFactory();
        Test.stopTest();

        System.assert(
            factory.getStrategy('Product') instanceof ProductMatchingStrategy,
            'Record Type Product deve mapear ProductMatchingStrategy'
        );
        System.assert(
            factory.getStrategy('Product_Family') instanceof FamilyMatchingStrategy,
            'Record Type Product_Family deve mapear FamilyMatchingStrategy'
        );
        System.assert(
            factory.getStrategy('Performance') instanceof PerformanceMatchingStrategy,
            'Record Type Performance deve mapear PerformanceMatchingStrategy'
        );
        System.assert(
            factory.getStrategy('Payment_Condition') instanceof PaymentConditionMatchingStrategy,
            'Record Type Payment_Condition deve mapear PaymentConditionMatchingStrategy'
        );
    }

    @isTest
    static void getStrategy_unknownRecordType_throws() {
        GoalMatchingStrategyFactory factory = new GoalMatchingStrategyFactory();

        Boolean threw = false;
        try {
            factory.getStrategy('Inexistente');
        } catch (GoalMatchingException e) {
            threw = true;
        }
        System.assert(threw, 'Record Type sem strategy deve lançar GoalMatchingException');
    }
}
