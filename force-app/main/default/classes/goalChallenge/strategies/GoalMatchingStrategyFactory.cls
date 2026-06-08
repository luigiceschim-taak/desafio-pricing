public with sharing class GoalMatchingStrategyFactory {

    private Map<String, IGoalMatchingStrategy> strategyByRecordType =
        new Map<String, IGoalMatchingStrategy>();

    // Mapeamento default usado quando não há registros ativos em Goal_Matching_Strategy__mdt.
    // O CMDT continua sendo a fonte primária de configuração; este map garante o funcionamento
    // mesmo sem registros publicados (a org atual rejeita o deploy de registros CMDT recém-criados).
    private static final Map<String, String> DEFAULT_MAPPING = new Map<String, String>{
        'Product'          => 'ProductMatchingStrategy',
        'Product_Family'   => 'FamilyMatchingStrategy',
        'Performance'      => 'PerformanceMatchingStrategy',
        'Payment_Condition' => 'PaymentConditionMatchingStrategy'
    };

    public GoalMatchingStrategyFactory() {
        loadFromCMDT();
        if (strategyByRecordType.isEmpty()) {
            loadDefaults();
        }
    }

    public IGoalMatchingStrategy getStrategy(String recordTypeDeveloperName) {
        IGoalMatchingStrategy strategy = strategyByRecordType.get(recordTypeDeveloperName);
        if (strategy == null) {
            throw new GoalMatchingException(
                'Nenhuma estratégia de match configurada para o Record Type: ' + recordTypeDeveloperName
            );
        }
        return strategy;
    }

    private void loadFromCMDT() {
        for (Goal_Matching_Strategy__mdt cfg : [
                SELECT RecordType_DeveloperName__c, Apex_Class_Name__c
                FROM Goal_Matching_Strategy__mdt
                WHERE Active__c = true
        ]) {
            register(cfg.RecordType_DeveloperName__c, cfg.Apex_Class_Name__c);
        }
    }

    private void loadDefaults() {
        for (String recordType : DEFAULT_MAPPING.keySet()) {
            register(recordType, DEFAULT_MAPPING.get(recordType));
        }
    }

    private void register(String recordTypeDeveloperName, String apexClassName) {
        Type implType = Type.forName(apexClassName);
        if (implType == null) {
            throw new GoalMatchingException('Classe Apex não encontrada: ' + apexClassName);
        }
        strategyByRecordType.put(
            recordTypeDeveloperName,
            (IGoalMatchingStrategy) implType.newInstance()
        );
    }
}
