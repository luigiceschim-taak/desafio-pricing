trigger PedidoTrigger on Order (before update, after update) {
   new PedidoHandler().run();
}