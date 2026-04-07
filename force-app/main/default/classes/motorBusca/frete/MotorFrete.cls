public class MotorFrete {
    private Map<String, Frete__c> mapaRegras;
    private List<FreteStrategy> estrategias;

    public MotorFrete(Map<String, Frete__c> regrasCarregadas) {
        this.mapaRegras = regrasCarregadas;
        // Define a ordem: 1º Tenta tudo de Produto, se falhar, tenta Hierarquia
        this.estrategias = new List<FreteStrategy>{
            new ProdutoStrategy(),
            new HierarquiaStrategy()
        };
    }

    public Frete__c buscar(ContextoFrete ctx) {
        for (FreteStrategy estrategia : estrategias) {
            Frete__c match = estrategia.search(ctx, this.mapaRegras);
            
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