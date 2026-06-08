public interface IOrderItemRepository {
    List<OrderItem_DTO> findByOwners(Set<Id> ownerIds);
}
