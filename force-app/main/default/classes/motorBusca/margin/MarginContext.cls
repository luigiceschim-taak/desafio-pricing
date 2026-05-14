public with sharing class MarginContext {
    public Id pId;   // Produto
    public Id hId;   // Hierarquia produto
    public Id cntId; // Conta
    public Id hCntId; // Hierarquia conta
    public Id cdId;  // Centro de Distribuição
    public Id paiId; // País
    public Id estId; // Estado
    public Id cidId; // Cidade

    public MarginContext(OrderItem item, Order ped, Id hierarquiaId) {
        this.pId    = item.Product2Id;
        this.hId    = hierarquiaId;
        this.cntId  = ped.AccountId;
        this.hCntId = (ped.Account != null) ? ped.Account.AccountGroup__c : null;
        this.cdId   = ped.DistributionCenter__c;

        if (ped.Address__c != null) {
            this.cidId = ped.Address__r.City__c;
            this.estId = ped.Address__r.City__r?.State__c;
            this.paiId = ped.Address__r.City__r?.State__r?.Country__c;
        }
    }
}