public virtual class MargemTriggerHandler {

    private static Set<String> bypassedHandlers = new Set<String>();

    public void run() {
        if (bypassedHandlers.contains(getHandlerName())) return;

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

    private String getHandlerName() {
        return String.valueOf(this).split(':').get(0);
    }

    // API de Bypass para desativar triggers via código
    public static void bypass(String handlerName) { bypassedHandlers.add(handlerName); }
    public static void clearBypass(String handlerName) { bypassedHandlers.remove(handlerName); }

}