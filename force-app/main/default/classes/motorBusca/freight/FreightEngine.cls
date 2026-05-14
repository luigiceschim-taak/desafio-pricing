public class FreightEngine {
    private Map<String, Freight__c> mapaRegras;
    private List<FreightStrategy> estrategias;

    public FreightEngine(Map<String, Freight__c> regrasCarregadas) {
        this.mapaRegras = regrasCarregadas;
        // Define a ordem: 1º Tenta tudo de Produto, se falhar, tenta Hierarquia
        this.estrategias = new List<FreightStrategy>{
            new ProductFreightStrategy(),
            new HierarchyFreightStrategy()
        };
    }

    public Freight__c buscar(FreightContext ctx) {
        for (FreightStrategy estrategia : estrategias) {
            Freight__c match = estrategia.search(ctx, this.mapaRegras);

            // Se a estratégia encontrou algo (!= null), retorne imediatamente!
            if (match != null) {
                System.debug('Match encontrado pela estrategia ' + estrategia + ': ' + match);
                return match;
            }
        }

        // Se percorreu todas as estratégias e nenhuma retornou nada
        System.debug('Nenhum match de frete encontrado para este contexto.');
        return null;
    }
}