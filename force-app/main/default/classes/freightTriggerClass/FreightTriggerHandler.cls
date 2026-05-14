public virtual class FreightTriggerHandler {


    public void run() {
        // Direciona para o método correto baseado no contexto da Trigger
        if (Trigger.isBefore && Trigger.isInsert) this.beforeInsert();
        else if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
    }

    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
}