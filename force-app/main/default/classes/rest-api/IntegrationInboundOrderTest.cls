@IsTest
public with sharing class IntegrationInboundOrderTest {
	@TestSetup
	public static void makeData() {
		TestFactorySObject sobjectFactory = TestFactorySObject.getInstance();

		Account newAccount = (Account)sobjectFactory.createSObject(new Account());
		insert newAccount;

		Product2 newProduct = (Product2)sobjectFactory.createSObject(new Product2());
		insert newProduct;

		PricebookEntry newPricebookEntry = (PricebookEntry)sobjectFactory.createSObject(
			new PricebookEntry(product2Id = newProduct.Id, Pricebook2Id = Test.getStandardPricebookId())
		);
		insert newPricebookEntry;

		Order newOrder = (Order)sobjectFactory.createSObject(
			new Order(AccountId = newAccount.Id, Pricebook2Id = Test.getStandardPricebookId(), ExternalId__c = 'CalloutOrder')
		);
		Order newOrderError = (Order)sobjectFactory.createSObject(
			new Order(AccountId = newAccount.Id, Pricebook2Id = Test.getStandardPricebookId(), ExternalId__c = 'CalloutOrderError')
		);
		insert (new List<Order>{ newOrder, newOrderError });

		OrderItem newOrderItem = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrder.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		OrderItem newOrderItem2 = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrder.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		insert (new List<OrderItem>{ newOrderItem, newOrderItem2 });

		OrderItem newOrderItemError = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrderError.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		OrderItem newOrderItemError2 = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrderError.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		insert (new List<OrderItem>{ newOrderItemError, newOrderItemError2 });
	}

	@IsTest
	public static void upsertOrderTest() {
		List<DataIntegrationFields.OrderINData> orderRequestList = fillOrderINDataList();
		System.debug('orderRequestList => ' + orderRequestList);
		System.debug('orderRequestList items => ' + orderRequestList[0].orderItemList);

		Test.startTest();
			IntegrationInboundOrder.upsertOrder(orderRequestList);
		Test.stopTest();
	}

	public static List<DataIntegrationFields.OrderINData> fillOrderINDataList() {
		List<Order> orderList = [SELECT Id, ExternalId__c, EffectiveDate, Status, Account.ExternalId__c, Pricebook2.ExternalId__c FROM Order LIMIT 2];

		DataIntegrationFields.OrderINData orderINData = fillOrderINData(orderList[0]);
		DataIntegrationFields.OrderINData orderINDataError = fillOrderINData(orderList[1]);
		orderINDataError.id = orderList[1].Id;
		orderINDataError.externalId = null;

		return new List<DataIntegrationFields.OrderINData>{ orderINData, orderINDataError };
	}

	public static DataIntegrationFields.OrderINData fillOrderINData(Order order) {
		DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();

		orderINData.externalId = order.ExternalId__c;
		orderINData.status = order.Status;
		orderINData.effectiveDate = String.valueOf(order.EffectiveDate);
		orderINData.accountExternalId = order.Account.ExternalId__c;
		orderINData.pricebook2ExternalId = order.Pricebook2.ExternalId__c;
		orderINData.orderItemList = fillOrderItemINDataList(order.Id);

		return orderINData;
	}

	public static List<DataIntegrationFields.OrderItemINData> fillOrderItemINDataList(String orderId) {
		OrderItem orderItem = 	[
									SELECT Id, ExternalId__c, Quantity, UnitPrice, Order.ExternalId__c, Product2.ExternalId__c, PricebookEntry.ExternalId__c
									FROM OrderItem
									WHERE OrderId =: orderId
									LIMIT 1
								];

		return new List<DataIntegrationFields.OrderItemINData>{ fillOrderItemINData(orderItem) };
	}

	public static DataIntegrationFields.OrderItemINData fillOrderItemINData(OrderItem orderItem) {
		DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

		orderItemINData.externalId = orderItem.ExternalId__c;
		orderItemINData.quantity = orderItem.Quantity;
		orderItemINData.unitPrice = orderItem.UnitPrice;
		orderItemINData.orderExternalId = orderItem.Order.ExternalId__c;
		orderItemINData.productExternalId = orderItem.Product2.ExternalId__c;
		orderItemINData.pricebookEntryExternalId = orderItem.PricebookEntry.ExternalId__c;

		return orderItemINData;
	}
}