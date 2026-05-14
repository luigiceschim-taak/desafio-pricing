public class MarginEngine {
    private Map<String, Margin__c> mapaRegras;
    private List<MarginStrategy> estrategias;

    public MarginEngine(Map<String, Margin__c> regrasCarregadas) {
        this.mapaRegras = regrasCarregadas;
        // Define a ordem: 1º Tenta tudo de Produto, se falhar, tenta Hierarquia
        this.estrategias = new List<MarginStrategy>{
            new ProductMarginStrategy(),
            new HierarchyMarginStrategy()
        };
    }

    public Margin__c buscar(MarginContext ctx) {
        for (MarginStrategy estrategia : estrategias) {
            Margin__c match = estrategia.search(ctx, this.mapaRegras);

            // Se a estratégia encontrou algo (!= null), retorne imediatamente!
            if (match != null) {
                System.debug('>>> [MarginEngine] Match encontrado por: ' + estrategia);
                return match;
            }
        }

        // Se percorreu todas as estratégias e nenhuma retornou nada
        System.debug('>>> [MarginEngine] Nenhum match de margem encontrado para este contexto.');
        return null;
    }
}