public virtual class ImpostoTriggerHandler {
    public void run() {
        // Direciona para o método correto baseado no contexto da Trigger
        if (Trigger.isBefore && Trigger.isInsert) this.beforeInsert();
        if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
    }
    // Métodos virtuais vazios para serem sobrescritos
    public virtual void beforeInsert() {}
    public virtual void beforeUpdate() {}
}