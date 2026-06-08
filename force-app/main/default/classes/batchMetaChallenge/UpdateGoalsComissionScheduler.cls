public with sharing class UpdateGoalsComissionScheduler implements Schedulable {
    // Tamanho do lote do batch (200 é o padrão; ajuste se precisar)
    private static final Integer BATCH_SIZE = 200;

    public void execute(SchedulableContext sc) {
        Database.executeBatch(new updateGoalsComissionBatch(), BATCH_SIZE);
    }
}
