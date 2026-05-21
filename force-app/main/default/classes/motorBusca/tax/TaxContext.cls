public with sharing class TaxContext {
    public Id pId;   // Product
    public Id cdId;  // Distribution Center
    public Id estId; // State

    public TaxContext(OrderItem item, Order order) {
        this.pId   = item.Product2Id;
        this.cdId  = order.DistributionCenter__c;

        if(order.Address__r != null) {
            this.estId = order.Address__r.City__r?.State__c;
        }

    }
}
