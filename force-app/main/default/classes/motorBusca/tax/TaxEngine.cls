public class TaxEngine {
    private Map<String, Tax__c> rulesMap;
    private List<TaxStrategy> strategies;

    public TaxEngine(Map<String, Tax__c> loadedRules) {
        this.rulesMap = loadedRules;
        this.strategies = new List<TaxStrategy>{
            new ProductTaxStrategy()
        };
    }

    public Tax__c find(TaxContext ctx) {
        for (TaxStrategy strategy : strategies) {
            Tax__c match = strategy.search(ctx, this.rulesMap);

            if (match != null) {
                return match;
            }
        }

        return null;
    }
}
