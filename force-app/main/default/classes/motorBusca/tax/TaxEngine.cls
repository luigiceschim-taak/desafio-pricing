public class TaxEngine {
    private Map<String, Tax__c> mapaRegras;
    private List<TaxStrategy> estrategias;

    public TaxEngine(Map<String, Tax__c> regrasCarregadas) {
        this.mapaRegras = regrasCarregadas;
        // Define a ordem: 1º Tenta tudo de Produto, se falhar, tenta Hierarquia
        this.estrategias = new List<TaxStrategy>{
            new ProductTaxStrategy()
        };
    }

    public Tax__c buscar(TaxContext ctx) {
        for (TaxStrategy estrategia : estrategias) {
            Tax__c match = estrategia.search(ctx, this.mapaRegras);

            // Se a estratégia encontrou algo (!= null), retorne imediatamente!
            if (match != null) {
                System.debug('Match encontrado pela estrategia ' + estrategia + ': ' + match);
                return match;
            }
        }

        // Se percorreu todas as estratégias e nenhuma retornou nada
        System.debug('Nenhum match de imposto encontrado para este contexto.');
        return null;
    }
}