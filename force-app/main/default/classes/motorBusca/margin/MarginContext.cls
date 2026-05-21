public with sharing class MarginContext {
    public Id pId;    // Product
    public Id hId;    // Product Hierarchy
    public Id cntId;  // Account
    public Id hCntId; // Account Group
    public Id cdId;   // Distribution Center
    public Id paiId;  // Country
    public Id estId;  // State
    public Id cidId;  // City

    public MarginContext(OrderItem item, Order order, Id hierarchyId) {
        this.pId    = item.Product2Id;
        this.hId    = hierarchyId;
        this.cntId  = order.AccountId;
        this.hCntId = (order.Account != null) ? order.Account.AccountGroup__c : null;
        this.cdId   = order.DistributionCenter__c;

        if (order.Address__c != null) {
            this.cidId = order.Address__r.City__c;
            this.estId = order.Address__r.City__r?.State__c;
            this.paiId = order.Address__r.City__r?.State__r?.Country__c;
        }
    }
}
