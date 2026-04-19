trigger ProdutoPedidoTrigger on OrderItem (before insert, after insert, before update) {
    new OrderItemHandler().run();

}