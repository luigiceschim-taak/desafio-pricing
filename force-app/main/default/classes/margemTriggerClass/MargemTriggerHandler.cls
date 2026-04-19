public virtual class MargemTriggerHandler {


    public void run() {
        if (Trigger.isBefore && Trigger.isInsert) this.beforeInsert();
        if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
    }

    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void beforeInsert() {}
    protected virtual void beforeUpdate() {}

  

}