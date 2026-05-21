public interface IPricingEngine {
    void calculatePrice(List<OrderItem> items, PricingContext context);

}
