public with sharing class ProductHandler extends ProductTriggerHandler {

    public override void afterInsert(){
        ProductService.createPriceBookEntry((List<Product2>) Trigger.new);
    }

}