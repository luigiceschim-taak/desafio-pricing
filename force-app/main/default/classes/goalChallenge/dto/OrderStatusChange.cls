public class OrderStatusChange {
    public Id orderId;
    public Id ownerId;
    public String fromStatus;
    public String toStatus;

    public OrderStatusChange() {}

    public OrderStatusChange(Id orderId, Id ownerId, String fromStatus, String toStatus) {
        this.orderId = orderId;
        this.ownerId = ownerId;
        this.fromStatus = fromStatus;
        this.toStatus = toStatus;
    }
}
