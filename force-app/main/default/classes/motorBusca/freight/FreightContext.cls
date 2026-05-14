public with sharing class FreightContext {

    public Id pId;   // Produto
    public Id hId;   // Hierarquia
    public Id cdId;  // Centro de Distribuição
    public Id cidId; // Cidade
    public Id estId; // Estado
    public Id paiId; // País

    // Construtor para facilitar a criação dentro do loop
    public FreightContext(OrderItem item, Order ped, Id hierarquiaId) {
        this.pId   = item.Product2Id;
        this.hId   = hierarquiaId;
        this.cdId  = ped.DistributionCenter__c;

        if(ped.Address__r != null) {
            this.cidId = ped.Address__r.City__c;
            this.estId = ped.Address__r.City__r?.State__c;
            this.paiId = ped.Address__r.City__r?.State__r?.Country__c;
        }

    }
}