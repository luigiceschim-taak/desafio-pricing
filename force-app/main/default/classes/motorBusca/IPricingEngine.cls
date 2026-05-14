public interface IPricingEngine {
    void calculatePrice(List<OrderItem> item, PricingContext contexto);

}