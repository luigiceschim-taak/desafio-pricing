public with sharing class ProdutoHandler extends ProdutoTriggerHandler {

    public override void afterInsert(){
        produtoService.createPriceBookEntry((List<Product2>) Trigger.new);
    }
  
}