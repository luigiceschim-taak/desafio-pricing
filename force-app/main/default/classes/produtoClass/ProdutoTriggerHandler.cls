public virtual class ProdutoTriggerHandler {

    public void run() {
      // Direciona para o método correto baseado no contexto da Trigger
        if (Trigger.isAfter && Trigger.isInsert) this.afterInsert();    
    }
    // Métodos virtuais vazios para serem sobrescritos
    protected virtual void afterInsert() {}
}