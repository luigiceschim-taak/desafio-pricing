public virtual class OrderTriggerHandler {
    public void run() {
        if (Trigger.isBefore && Trigger.isUpdate) this.beforeUpdate();
        if (Trigger.isAfter && Trigger.isUpdate) this.afterUpdate();
    }

    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void beforeUpdate() {}
    protected virtual void afterUpdate() {}



}