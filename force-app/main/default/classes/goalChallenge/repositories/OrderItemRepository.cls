public with sharing class OrderItemRepository implements IOrderItemRepository {

    // A condição de pagamento mora no Order (PaymentTerm__c), não no OrderItem;
    // o match com a meta é feito pelo Name. O valor somado é o TotalPrice da linha.
    public List<OrderItem_DTO> findByOwners(Set<Id> ownerIds) {
        List<OrderItem_DTO> result = new List<OrderItem_DTO>();

        for (OrderItem oi : [
                SELECT Id, Product2Id, Product2.Family, TotalPrice,
                       Order.OwnerId, Order.Status, Order.PaymentTerm__r.Name
                FROM OrderItem
                WHERE Order.OwnerId IN :ownerIds
        ]) {
            OrderItem_DTO dto = new OrderItem_DTO();
            dto.id = oi.Id;
            dto.ownerId = oi.Order.OwnerId;
            dto.orderStatus = oi.Order.Status;
            dto.productId = oi.Product2Id;
            dto.productFamily = oi.Product2.Family;
            dto.paymentCondition = oi.Order.PaymentTerm__r.Name;
            dto.amount = oi.TotalPrice;
            result.add(dto);
        }
        return result;
    }
}
