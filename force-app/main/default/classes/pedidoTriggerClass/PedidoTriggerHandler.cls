public virtual class PedidoTriggerHandler {
    public void run() {

        // Direciona para o método correto baseado no contexto da Trigger
        if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
        if (Trigger.isAfter && Trigger.isUpdate) this.afterUpdate();
        // Adicione outros contextos se necessário (Delete, Undelete)
    }

    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void beforeUpdate() {}
    protected virtual void afterUpdate() {}

   

}