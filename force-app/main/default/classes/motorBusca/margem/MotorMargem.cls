public class MotorMargem {
    private Map<String, Margem__c> mapaRegras;
    private List<MargemStrategy> estrategias;

    public MotorMargem(Map<String, Margem__c> regrasCarregadas) {
        this.mapaRegras = regrasCarregadas;
        // Define a ordem: 1º Tenta tudo de Produto, se falhar, tenta Hierarquia
        this.estrategias = new List<MargemStrategy>{
            new MargemProdutoStrategy(),
            new MargemHierarquiaStrategy()
        };
    }

    public Margem__c buscar(ContextoMargem ctx) {
        for (MargemStrategy estrategia : estrategias) {
            Margem__c match = estrategia.search(ctx, this.mapaRegras);
            
            // Se a estratégia encontrou algo (!= null), retorne imediatamente!
            if (match != null) {
                System.debug('>>> [MotorMargem] Match encontrado por: ' + estrategia);
                return match; 
            }
        }
        
        // Se percorreu todas as estratégias e nenhuma retornou nada
        System.debug('>>> [MotorMargem] Nenhum match de margem encontrado para este contexto.');
        return null;
    }
}