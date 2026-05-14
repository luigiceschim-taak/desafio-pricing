trigger OrderTrigger on Order (before update, after update) {
    new OrderHandler().run();
}