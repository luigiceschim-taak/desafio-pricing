@isTest
private class UpdateGoalsComissionBatchTest {

    @TestSetup
    static void setup() {
        Goal__c goal = new Goal__c(Name = 'Meta Teste', Year__c = 2026);
        insert goal;

        List<GoalItem__c> items = new List<GoalItem__c>();

        // 1) Realizado > Meta  -> deve copiar Goal_Comission_Percent__c (10) para Percentage_Achieved__c
        items.add(new GoalItem__c(
            Name = 'Item Acima',
            Goal__c = goal.Id,
            Goal_Amount__c = 1000,
            Realized_Value__c = 1500,
            Goal_Comission_Percent__c = 10,
            Percentage_Achieved__c = 99
        ));

        // 2) Realizado = Meta  -> com >= também copia (5)
        items.add(new GoalItem__c(
            Name = 'Item Igual',
            Goal__c = goal.Id,
            Goal_Amount__c = 1000,
            Realized_Value__c = 1000,
            Goal_Comission_Percent__c = 5,
            Percentage_Achieved__c = 99
        ));

        // 3) Realizado < Meta  -> nao deve ser alterado (permanece 99)
        items.add(new GoalItem__c(
            Name = 'Item Abaixo',
            Goal__c = goal.Id,
            Goal_Amount__c = 1000,
            Realized_Value__c = 500,
            Goal_Comission_Percent__c = 10,
            Percentage_Achieved__c = 99
        ));

        // 4) Campos nulos -> deve ser ignorado (permanece 99)
        items.add(new GoalItem__c(
            Name = 'Item Nulo',
            Goal__c = goal.Id,
            Goal_Amount__c = null,
            Realized_Value__c = null,
            Goal_Comission_Percent__c = 10,
            Percentage_Achieved__c = 99
        ));

        insert items;
    }

    @isTest
    static void testBatchAtualizaPercentual() {
        Test.startTest();
        Database.executeBatch(new updateGoalsComissionBatch(), 200);
        Test.stopTest();

        Map<String, GoalItem__c> byName = new Map<String, GoalItem__c>();
        for (GoalItem__c gi : [
            SELECT Name, Percentage_Achieved__c
            FROM GoalItem__c
        ]) {
            byName.put(gi.Name, gi);
        }

        System.assertEquals(10, byName.get('Item Acima').Percentage_Achieved__c,
            'Realizado > meta deve copiar o % de comissao');
        System.assertEquals(5, byName.get('Item Igual').Percentage_Achieved__c,
            'Realizado = meta (>=) deve copiar o % de comissao');
        System.assertEquals(99, byName.get('Item Abaixo').Percentage_Achieved__c,
            'Realizado < meta nao deve ser alterado (permanece o valor original)');
        System.assertEquals(99, byName.get('Item Nulo').Percentage_Achieved__c,
            'Campos nulos devem ser ignorados');

        // Sales_Amount__c do Goal = soma do Realizado apenas dos itens batidos (1500 + 1000).
        Goal__c goal = [SELECT Sales_Amount__c FROM Goal__c LIMIT 1];
        System.assertEquals(2500, goal.Sales_Amount__c,
            'Valor de vendas deve somar o Realizado das metas batidas');
    }

    @isTest
    static void testScheduler() {
        String cron = '0 0 9 * * ?';

        Test.startTest();
        String jobId = System.schedule(
            'Update Goals Comission Test',
            cron,
            new UpdateGoalsComissionScheduler()
        );
        Test.stopTest();

        CronTrigger ct = [
            SELECT Id, CronExpression, State
            FROM CronTrigger
            WHERE Id = :jobId
        ];
        System.assertEquals(cron, ct.CronExpression, 'A expressao cron deve coincidir');
    }
}
