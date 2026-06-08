public with sharing class updateGoalsComissionBatch implements Database.Batchable<SObject> {

    public updateGoalsComissionBatch() {}

    // Itera por Goal (com os itens em subquery) para agregar o valor de vendas por meta
    // numa única passagem, sem risco de itens da mesma meta caírem em chunks diferentes.
    public Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(
            'SELECT Id, Sales_Amount__c, ' +
            '(SELECT Id, Goal_Amount__c, Realized_Value__c, Goal_Comission_Percent__c, Percentage_Achieved__c ' +
            ' FROM Itens_Das_Metas__r) ' +
            'FROM Goal__c'
        );
    }

    public void execute(Database.BatchableContext BC, List<Goal__c> scope) {
        List<GoalItem__c> itemsToUpdate = new List<GoalItem__c>();
        List<Goal__c> goalsToUpdate = new List<Goal__c>();

        for (Goal__c goal : scope) {
            Decimal salesAmount = 0;

            for (GoalItem__c item : goal.Itens_Das_Metas__r) {
                Boolean achieved = item.Realized_Value__c != null
                    && item.Goal_Amount__c != null
                    && item.Realized_Value__c >= item.Goal_Amount__c;

                if (achieved) {
                    // Marca a comissão atingida no item (alimenta o rollup Comission_Percent__c do Goal).
                    item.Percentage_Achieved__c = item.Goal_Comission_Percent__c;
                    itemsToUpdate.add(item);

                    // Valor de vendas = soma do Realizado apenas das metas batidas.
                    salesAmount += item.Realized_Value__c;
                }
            }

            // Sales_Amount__c alimenta a fórmula Commission_Amount__c (Comission_Percent__c * Sales_Amount__c).
            goalsToUpdate.add(new Goal__c(Id = goal.Id, Sales_Amount__c = salesAmount));
        }

        if (!itemsToUpdate.isEmpty()) {
            update itemsToUpdate;
        }
        if (!goalsToUpdate.isEmpty()) {
            update goalsToUpdate;
        }
    }

    public void finish(Database.BatchableContext BC) {
        System.debug('Batch process completed. Job: ' + BC.getJobId());
    }
}
