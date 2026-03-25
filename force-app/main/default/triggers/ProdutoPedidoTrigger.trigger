trigger ProdutoPedidoTrigger on OrderItem (before insert, after insert, before update, after update) {
    new OrderItemHandler().run();

}