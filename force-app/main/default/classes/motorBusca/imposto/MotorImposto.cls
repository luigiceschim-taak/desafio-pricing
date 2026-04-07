public class MotorImposto {
    private Map<String, Imposto__c> mapaRegras;
    private List<ImpostoStrategy> estrategias;

    public MotorImposto(Map<String, Imposto__c> regrasCarregadas) {
        this.mapaRegras = regrasCarregadas;
        // Define a ordem: 1º Tenta tudo de Produto, se falhar, tenta Hierarquia
        this.estrategias = new List<ImpostoStrategy>{
            new ProdutoImpostoStrategy()
        };
    }

    public Imposto__c buscar(ContextoImposto ctx) {
        for (ImpostoStrategy estrategia : estrategias) {
            Imposto__c match = estrategia.search(ctx, this.mapaRegras);
            
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