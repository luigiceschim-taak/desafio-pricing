public virtual class TriggerHandler {
    public void run() {

        // Direciona para o método correto baseado no contexto da Trigger
        if (Trigger.isBefore && Trigger.isInsert) this.beforeInsert();
        if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
        if (Trigger.isAfter && Trigger.isInsert) this.afterInsert();
        // Adicione outros contextos se necessário (Delete, Undelete)
    }

    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void afterInsert() {}

}
