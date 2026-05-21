public class FreightEngine {
    private Map<String, Freight__c> rulesMap;
    private List<FreightStrategy> strategies;

    public FreightEngine(Map<String, Freight__c> loadedRules) {
        this.rulesMap = loadedRules;
        this.strategies = new List<FreightStrategy>{
            new ProductFreightStrategy(),
            new HierarchyFreightStrategy()
        };
    }

    public Freight__c find(FreightContext ctx) {
        for (FreightStrategy strategy : strategies) {
            Freight__c match = strategy.search(ctx, this.rulesMap);

            if (match != null) {
                return match;
            }
        }

        return null;
    }
}
