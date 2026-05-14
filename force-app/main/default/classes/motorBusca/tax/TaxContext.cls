public with sharing class TaxContext {
    public Id pId;   // Produto
    public Id cdId;  // Centro de Distribuição
    public Id estId; // Estado

    // Construtor para facilitar a criação dentro do loop
    public TaxContext(OrderItem item, Order ped) {
        this.pId   = item.Product2Id;
        this.cdId  = ped.DistributionCenter__c;

        if(ped.Address__r != null) {
            this.estId = ped.Address__r.City__r?.State__c;
        }

    }
}