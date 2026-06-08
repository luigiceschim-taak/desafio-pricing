public with sharing class GoalMatchingEngine {

    private final GoalMatchingStrategyFactory factory;

    public GoalMatchingEngine(GoalMatchingStrategyFactory factory) {
        this.factory = factory;
    }

    // Aplica a strategy correta a cada Goal Item; um MatchResult por item (captura a relação N:N).
    public List<MatchResult> matchAll(List<OrderItem_DTO> orderItems, List<GoalItem_DTO> goalItems) {
        List<MatchResult> results = new List<MatchResult>();
        for (GoalItem_DTO goalItem : goalItems) {
            IGoalMatchingStrategy strategy = factory.getStrategy(goalItem.recordTypeDeveloperName);
            MatchResult result = new MatchResult(goalItem.id);
            result.matchedItems = strategy.match(orderItems, goalItem);
            results.add(result);
        }
        return results;
    }
}
