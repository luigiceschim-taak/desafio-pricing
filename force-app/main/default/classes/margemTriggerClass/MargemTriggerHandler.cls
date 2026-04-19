public virtual class MargemTriggerHandler {


    public void run() {
      

        // Direciona para o método correto baseado no contexto da Trigger
        if (Trigger.isBefore && Trigger.isInsert) this.beforeInsert();
        else if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
        else if (Trigger.isAfter && Trigger.isInsert) this.afterInsert();
        else if (Trigger.isAfter && Trigger.isUpdate) this.afterUpdate();
        // Adicione outros contextos se necessário (Delete, Undelete)
    }

    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}
    protected virtual void afterInsert() {}
    protected virtual void afterUpdate() {}

  

}