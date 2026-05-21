public class PricingContext {
    public Map<Id, Order> mapOrders = new Map<Id, Order>();
    public Map<Id, Product2> mapProducts = new Map<Id, Product2>();

    public BulkFreightContext freight = new BulkFreightContext();
    public BulkMarginContext margin = new BulkMarginContext();
    public BulkTaxContext tax = new BulkTaxContext();

    public class BulkFreightContext {
        public Set<Id> productIds = new Set<Id>();
        public Set<Id> hierarchyIds = new Set<Id>();
        public Set<Id> dcIds = new Set<Id>();
        public Set<Id> locationIds = new Set<Id>();
    }

    public class BulkMarginContext {
        public Set<Id> productIds = new Set<Id>();
        public Set<Id> hierarchyIds = new Set<Id>();
        public Set<Id> accountIds = new Set<Id>();
        public Set<Id> accountGroupIds = new Set<Id>();
        public Set<Id> dcIds = new Set<Id>();
        public Set<Id> locationIds = new Set<Id>();
    }

    public class BulkTaxContext {
        public Set<Id> productIds = new Set<Id>();
        public Set<Id> dcIds = new Set<Id>();
        public Set<Id> locationIds = new Set<Id>();
    }

}
