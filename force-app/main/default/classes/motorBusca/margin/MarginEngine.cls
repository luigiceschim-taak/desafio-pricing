public class MarginEngine {
    private Map<String, Margin__c> rulesMap;
    private List<MarginStrategy> strategies;

    public MarginEngine(Map<String, Margin__c> loadedRules) {
        this.rulesMap = loadedRules;
        this.strategies = new List<MarginStrategy>{
            new ProductMarginStrategy(),
            new HierarchyMarginStrategy()
        };
    }

    public Margin__c find(MarginContext ctx) {
        for (MarginStrategy strategy : strategies) {
            Margin__c match = strategy.search(ctx, this.rulesMap);

            if (match != null) {
                return match;
            }
        }

        return null;
    }
}
