public with sharing class ContextoImposto {
    public ContextoImposto() {

    }
    public Id pId;   // Produto
    public Id cdId;  // Centro de Distribuição 
    public Id estId; // Estado

    // Construtor para facilitar a criação dentro do loop
    public ContextoImposto(OrderItem item, Order ped) {
        this.pId   = item.Product2Id;
        this.cdId  = ped.Centro_Distribuicao__c;
        
        if(ped.Endereco__r != null) {
            this.estId = ped.Endereco__r.Cidade__r?.Estado__c; // O ?. evita erro se Cidade for nula
        }

    }
}
