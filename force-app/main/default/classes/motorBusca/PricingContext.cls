// A NOSSA "BANDEJA" MESTRE (DTO)
public class PricingContext {
    // Mapas de Apoio (Para as Engines consultarem)
    public Map<Id, Order> mapPedidos = new Map<Id, Order>();
    public Map<Id, Product2> mapProdutos = new Map<Id, Product2>();

    // As "Malinhas" (Para os Selectors buscarem no banco)
    public BulkFreightContext frete = new BulkFreightContext();
    public BulkMarginContext margem = new BulkMarginContext();
    public BulkTaxContext imposto = new BulkTaxContext();

    // Inner Classes (As Malinhas)
    public class BulkFreightContext {
        public Set<Id> produtosIds = new Set<Id>();
        public Set<Id> hierarquiasIds = new Set<Id>();
        public Set<Id> cdsIds = new Set<Id>();
        public Set<Id> locaisIds = new Set<Id>(); // Cidades, Estados, Países
    }

    public class BulkMarginContext {
        public Set<Id> produtosIds = new Set<Id>();
        public Set<Id> hierarquiasIds = new Set<Id>();
        public Set<Id> contasIds = new Set<Id>();
        public Set<Id> hContasIds = new Set<Id>();
        public Set<Id> cdsIds = new Set<Id>();
        public Set<Id> locaisIds = new Set<Id>(); // Cidades, Estados, Países
    }

    public class BulkTaxContext {
        public Set<Id> produtosIds = new Set<Id>();
        public Set<Id> cdsIds = new Set<Id>();
        public Set<Id> locaisIds = new Set<Id>(); // Cidades, Estados, Países

    }

}