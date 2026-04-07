public with sharing class ContextoMargem {
    public ContextoMargem() {

    }
    public Id pId;   // Produto
    public Id hId;   // Hierarquia produto
    public Id cntId; // conta
    public Id hCntId; // hierarquia conta
    public Id cdId;  // Centro de Distribuição 
    public Id paiId; // País
    public Id estId; // Estado
    public Id cidId; // Cidade

    // Construtor para facilitar a criação dentro do loop
    public ContextoMargem(OrderItem item, Order ped) {
        this.pId    = item.Product2Id;
        this.hId    = (item.Product2 != null) ? item.Product2.Hierarquia_Produto__c : null;
        this.cntId  = ped.AccountId;
        this.hCntId = (ped.Account != null) ? ped.Account.Grupo_Clientes__c : null;
        this.cdId   = ped.Centro_Distribuicao__c;
        
        if(ped.Endereco__c!= null) {
            this.cidId = ped.Endereco__r.Cidade__c;
            this.estId = ped.Endereco__r.Cidade__r.Estado__c;
            this.paiId = ped.Endereco__r.Cidade__r.Estado__r.Pais__c;

            
            
        }
    }
}
