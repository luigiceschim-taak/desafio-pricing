@IsTest
public with sharing class FactoryDataIntegrationTest {
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
			new Order(AccountId = newAccount.Id, Pricebook2Id = Test.getStandardPricebookId(), ExternalId__c = 'Class Test')
		);
		insert newOrder;

		OrderItem newOrderItem = (OrderItem)sobjectFactory.createSObject(
			new OrderItem(OrderId = newOrder.Id, Product2Id = newProduct.Id, PricebookEntryId = newPricebookEntry.Id)
		);
		insert newOrderItem;
	}

	@IsTest
	public static void convertSObjectErrorTest() {
		List<DataIntegrationFields.OrderINData> orderRequestList = fillOrderINDataListError();
		List<DataIntegrationFields.ResponseParent> responseList = new List<DataIntegrationFields.ResponseParent>();
		List<Order> orderToUpsertList = new List<Order>();

		Test.startTest();
			FactoryDataIntegration.convertSObject(new Order(), 'IN', orderRequestList, responseList, orderToUpsertList);
		Test.stopTest();
	}

	@IsTest
	public static void validateObjectChildErrorTest() {
		List<DataIntegrationFields.OrderItemINData> orderItemRequestList = fillOrderItemINDataListError();
		Map<String, List<DataIntegrationFields.Response>> responseMap = new Map<String, List<DataIntegrationFields.Response>>();
		List<OrderItem> orderItemToUpsertList = new List<OrderItem>();

		Test.startTest();
			FactoryDataIntegration.convertSObjectChild(new OrderItem(), 'IN', orderItemRequestList, responseMap, orderItemToUpsertList);
		Test.stopTest();
	}

	public static List<DataIntegrationFields.OrderINData> fillOrderINDataListError() {
		Order order = [SELECT Id, ExternalId__c, EffectiveDate, Status, AccountId, Pricebook2Id FROM Order LIMIT 1];

		DataIntegrationFields.OrderINData orderINData = fillOrderINData(order);
		DataIntegrationFields.OrderINData orderINDataWithId = fillOrderINData(order);
		orderINDataWithId.id = order.Id;

		List<DataIntegrationFields.OrderINData> orderRequest = new List<DataIntegrationFields.OrderINData>{ orderINData, orderINDataWithId };

		return orderRequest;
	}

	public static List<DataIntegrationFields.OrderItemINData> fillOrderItemINDataListError() {
		OrderItem orderItem = [SELECT Id, ExternalId__c, Quantity, UnitPrice, OrderId, Product2Id, PricebookEntryId FROM OrderItem LIMIT 1];

		List<DataIntegrationFields.OrderItemINData> orderItemRequest = new List<DataIntegrationFields.OrderItemINData>{
			fillOrderItemINData(orderItem)
		};

		return orderItemRequest;
	}

	public static DataIntegrationFields.OrderINData fillOrderINData(Order order) {
		DataIntegrationFields.OrderINData orderINData = new DataIntegrationFields.OrderINData();

		orderINData.externalId = order.ExternalId__c;
		//orderINData.effectiveDate = order.EffectiveDate;
		orderINData.status = order.Status;
		orderINData.accountExternalId = order.AccountId;
		orderINData.pricebook2ExternalId = order.Pricebook2Id;
		orderINData.orderItemList = new List<DataIntegrationFields.OrderItemINData>();

		return orderINData;
	}

	public static DataIntegrationFields.OrderItemINData fillOrderItemINData(OrderItem orderItem) {
		DataIntegrationFields.OrderItemINData orderItemINData = new DataIntegrationFields.OrderItemINData();

		//orderItemINData.externalId = orderItem.ExternalId__c;
		orderItemINData.quantity = orderItem.Quantity;
		orderItemINData.unitPrice = orderItem.UnitPrice;
		orderItemINData.orderExternalId = orderItem.OrderId;
		orderItemINData.productExternalId = orderItem.Product2Id;
		orderItemINData.pricebookEntryExternalId = orderItem.PricebookEntryId;

		return orderItemINData;
	}
}