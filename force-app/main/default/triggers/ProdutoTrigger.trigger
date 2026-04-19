trigger ProdutoTrigger on Product2 (after insert) {
     new ProdutoHandler().run();

}