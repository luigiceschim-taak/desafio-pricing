public with sharing class ContextoFrete {
    
    public Id pId;   // Produto
    public Id hId;   // Hierarquia
    public Id cdId;  // Centro de Distribuição 
    public Id cidId; // Cidade
    public Id estId; // Estado
    public Id paiId; // País

    // Construtor para facilitar a criação dentro do loop
    public ContextoFrete(OrderItem item, Order ped, Id hierarquiaId) {
        this.pId   = item.Product2Id;
        this.hId   = hierarquiaId;
        this.cdId  = ped.Centro_Distribuicao__c;
        
        if(ped.Endereco__r != null) {
            this.cidId = ped.Endereco__r.Cidade__c;
            this.estId = ped.Endereco__r.Cidade__r?.Estado__c; // O ?. evita erro se Cidade for nula
            this.paiId = ped.Endereco__r.Cidade__r?.Estado__r?.Pais__c;
        }

    }
}
