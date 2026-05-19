@RestResource(urlMapping='/upsertOneOrder/*')
global with sharing class IntegrationInboundOneOrder {
	@HttpPost
	global static DataIntegrationFields.Response upsertOrder(DataIntegrationFields.OrderINData orderRequest) {
		List<DataIntegrationFields.OrderINData> orderRequestList = new List<DataIntegrationFields.OrderINData>{ orderRequest };
		System.debug('orderRequestList => ' + orderRequestList);
		Boolean hasError = false;
		Boolean hasDeleted = false;
		String orderExternalIds = '';
		List<Order> orderToUpsertList = new List<Order>();
		Map<String, String> orderExternalIdToOrderItem = new Map<String, String>();
		List<DataIntegrationFields.ResponseParent> orderResponseList = new List<DataIntegrationFields.ResponseParent>();
		List<DataIntegrationFields.OrderItemINData> orderItemToUpsertList = fillOrderExternalIdInOrderItem(orderRequestList, orderExternalIdToOrderItem);
		Map<String, List<DataIntegrationFields.Response>> orderItemResponseList = new Map<String, List<DataIntegrationFields.Response>>();

		// Converting template to object list and validating required fields
		orderExternalIds = FactoryDataIntegration.convertSObject(new Order(), 'IN', orderRequestList, orderResponseList, orderToUpsertList);
		// Upserting records (Order)
		hasError = IntegrationUtils.upsertRecords(
			Database.upsert(orderToUpsertList, Order.ExternalId__c, false), orderResponseList, orderToUpsertList, Order.ExternalId__c
		);

		// Mark OrderItem as deleted if not received
		hasDeleted = deletedOrderItem(orderItemToUpsertList, false); // true => Apaga o OrderItem, false => Marca o OrderItem como deletado (Campo Boolean)
		// Upserting OrderItems
		if (!orderItemToUpsertList.isEmpty()) orderItemResponseList.putAll(upsertOrderItem(orderItemToUpsertList, orderExternalIdToOrderItem, hasDeleted));
		// Fill response list with items
		if (!orderItemResponseList.isEmpty()) hasError = fillResponseList(orderResponseList, orderItemResponseList);

		String endpoint = System.Url.getOrgDomainUrl().toExternalForm() + '/services/apexrest/upsertOneOrder/*';
		String integrationLogId = IntegrationLog.createLog(
			'Order', orderExternalIds, 'Inbound', JSON.serialize(orderRequestList), JSON.serialize(orderResponseList), '', endpoint, hasError, hasDeleted, orderExternalIds
		);
		if (integrationLogId != null) updateOrderWithIntegrationLogId(orderToUpsertList, integrationLogId, 'IN');

		System.debug('orderResponseList => ' + orderResponseList);
		return orderResponseList[0];
	}

	public static List<DataIntegrationFields.OrderItemINData> fillOrderExternalIdInOrderItem(List<DataIntegrationFields.OrderINData> orderRequestList,
																							Map<String, String> orderExternalIdToOrderItem) {
		List<DataIntegrationFields.OrderItemINData> orderItemToUpsertList = new List<DataIntegrationFields.OrderItemINData>();

		for (DataIntegrationFields.OrderINData order : orderRequestList){
			if (order.orderItemList != null) {
				// Putting the Order's ExternalId parameter in the OrderItem
				for (DataIntegrationFields.OrderItemINData orderItem : order.orderItemList) {
					orderExternalIdToOrderItem.put(orderItem.externalId, order.externalId);
					orderItem.orderExternalId = order.externalId;
				}

				orderItemToUpsertList.addAll(order.orderItemList);
			}
		}

		return orderItemToUpsertList;
	}

	public static Map<String, List<DataIntegrationFields.Response>> upsertOrderItem(List<DataIntegrationFields.OrderItemINData> orderItemRequestList,
																					Map<String, String> orderExternalIdToOrderItem, Boolean hasDeleted) {
		Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
		List<OrderItem> orderItemToUpsertList = new List<OrderItem>();

		// Converting template to object list and validating required fields
		FactoryDataIntegration.convertSObjectChild(new OrderItem(), 'IN', orderItemRequestList, responseMap, orderItemToUpsertList);

		// Upserting records
		List<Database.UpsertResult> upsertResults = Database.upsert(orderItemToUpsertList, OrderItem.ExternalId__c, false);
		IntegrationUtils.upsertChildRecords(upsertResults, responseMap, orderItemToUpsertList, orderExternalIdToOrderItem, OrderItem.ExternalId__c);

		return responseMap;
	}

	public static Boolean deletedOrderItem(List<DataIntegrationFields.OrderItemINData> orderItemRequestList, Boolean willDeleted) {
		List<OrderItem> deleteOrderItemList = new List<OrderItem>();
		List<OrderItem> updateOrderItemList = new List<OrderItem>();
		Set<String> orderItemExternalIdSet = new Set<String>();
		Set<String> orderExternalIdSet = new Set<String>();

		for (DataIntegrationFields.OrderItemINData orderItemData : orderItemRequestList) {
			orderItemExternalIdSet.add(orderItemData.externalId);
			orderExternalIdSet.add(orderItemData.orderExternalId);
		}

		for (OrderItem orderItem : [
										SELECT Id, DeletedProduct__c
										FROM OrderItem
										WHERE ExternalId__c NOT IN: orderItemExternalIdSet
										AND Order.ExternalId__c IN: orderExternalIdSet
										AND DeletedProduct__c = false
									]) {
			if (willDeleted) deleteOrderItemList.add(orderItem);
			else {
				orderItem.DeletedProduct__c = true;
				updateOrderItemList.add(orderItem);
			}
		}

		if (!deleteOrderItemList.isEmpty()) delete deleteOrderItemList;
		if (!updateOrderItemList.isEmpty()) update updateOrderItemList;

		return (!deleteOrderItemList.isEmpty() || !updateOrderItemList.isEmpty());
	}

	public static Boolean fillResponseList(List<DataIntegrationFields.ResponseParent> orderResponseList,
										Map<String, List<DataIntegrationFields.Response>> orderItemResponseList) {
		Boolean hasError = false;

		// Associating child object's response with object response
		for (DataIntegrationFields.ResponseParent response : orderResponseList) {
			response.items = new List<DataIntegrationFields.Response>();

			if (orderItemResponseList.containsKey(response.externalId))
				response.items.addAll(orderItemResponseList.get(response.externalId));
			else if (orderItemResponseList.containsKey(response.salesforceId))
				response.items.addAll(orderItemResponseList.get(response.salesforceId));
		}

		// Checking integration errors to log
		for (DataIntegrationFields.ResponseParent responseOrder : orderResponseList) {
			if (responseOrder.hasError) {
				hasError = true;
				break;
			}
			else {
				for (DataIntegrationFields.Response response : responseOrder.items) {
					if (response.hasError) {
						hasError = true;
						break;
					}
				}
			}
		}

		return hasError;
	}

	public static void updateOrderWithIntegrationLogId(List<Order> orderList, String integrationLogId, String integrationType) {
		List<Order> orderUpdateList = new List<Order>();

		for (Order order : [SELECT Id, IntegrationLogInbound__c, IntegrationLogOutbound__c FROM Order WHERE Id IN: orderList]) {
			if (integrationType == 'IN') order.IntegrationLogInbound__c = integrationLogId;
			else order.IntegrationLogOutbound__c = integrationLogId;

			orderUpdateList.add(order);
		}

		if (!orderUpdateList.isEmpty()) update orderUpdateList;
	}
}