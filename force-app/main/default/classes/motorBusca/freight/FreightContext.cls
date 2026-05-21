public with sharing class FreightContext {

    public Id pId;   // Product
    public Id hId;   // Hierarchy
    public Id cdId;  // Distribution Center
    public Id cidId; // City
    public Id estId; // State
    public Id paiId; // Country

    public FreightContext(OrderItem item, Order order, Id hierarchyId) {
        this.pId   = item.Product2Id;
        this.hId   = hierarchyId;
        this.cdId  = order.DistributionCenter__c;

        if(order.Address__r != null) {
            this.cidId = order.Address__r.City__c;
            this.estId = order.Address__r.City__r?.State__c;
            this.paiId = order.Address__r.City__r?.State__r?.Country__c;
        }

    }
}
