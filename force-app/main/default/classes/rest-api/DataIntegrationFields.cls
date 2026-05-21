global with sharing class DataIntegrationFields {
	public interface FieldData {
		List<String> getRequiredFields();
		String getFieldKey();
		String getFieldId();
		String getExternalId();
		SObject deserialize();
	}

	public interface FieldDataChild {
		List<String> getRequiredFields();
		String getFieldId();
		String getFieldExternal();
		String getParentId();
		String getParentKey();
		SObject deserialize();
	}

	global class OrderINData implements FieldData {
		public String id;
		public String externalId;
        public String status;
        public String effectiveDate;
        public String accountExternalId;
        public String pricebook2ExternalId;
        public String shippingType;
        public String addressName;
        public String distributionCenterName;
        public String deliveryDate;
        public String paymentTermsName;
        public String contractExternalId;

		public List<OrderItemINData> orderItemList {get; set;}

		public Order deserialize() {
			return new Order(
				ExternalId__c = this.externalId,
                Status = this.status,
                EffectiveDate = String.isNotEmpty(this.effectiveDate)
                  ? Date.valueOf(this.effectiveDate)
                  : null,
                FreightType__c = this.shippingType,
                Account = new Account(ExternalId__c = this.accountExternalId),
                Pricebook2 = new Pricebook2(ExternalId__c = this.pricebook2ExternalId),
                Address__r = new Address__c(PostalCode__c = this.addressName),
                DistributionCenter__r = new DistributionCenter__c(
                  Name = this.distributionCenterName
                ),
                DeliveryDate__c = String.isNotEmpty(this.deliveryDate)
                  ? Date.valueOf(this.deliveryDate)
                  : null,
                PaymentTerm__r = new PaymentTerm__c(Name = this.paymentTermsName),
                Contract = new Contract(ExternalId__c = this.contractExternalId)
			);
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'ExternalId__c',
				'EffectiveDate',
				'Status'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'AccountId',
				'Pricebook2Id'
			};
		}

		public String getFieldKey() {
			return 'ExternalId__c';
		}
		public String getFieldId() {
			return 'Id';
		}
		public String getExternalId() {
			return this.externalId;
		}
	}
	global class OrderItemINData implements FieldDataChild { // extends OrderItemBase
        public String id;
        public String externalId;
        public Decimal quantity;
        public String orderExternalId;
        public Decimal unitPrice;
        public Decimal sellingPrice;
        public Decimal productionCost;
        public String productExternalId;
        public String pricebookEntryExternalId;

		public OrderItem deserialize() {
			OrderItem orderItem = new OrderItem(
				ExternalId__c	= this.externalId,
				Quantity		= this.quantity,
				UnitPrice		= this.unitPrice,
				PricebookEntry	= new PricebookEntry(ExternalId__c = this.pricebookEntryExternalId),
                ProductionCost__c = this.productionCost
			);

			if (this.id == null || this.id == '') {
				orderItem.Order				= new Order(ExternalId__c = this.orderExternalId);
			}
			else orderItem.Id = this.id;

			return orderItem;
		}

		public List<String> getRequiredFields() {
			return new List<String>{
				'UnitPrice',
				'Quantity',
				'ExternalId__c'
			};
		}
		public List<String> getRequiredLookups() {
			return new List<String>{
				'OrderId',
				'Product2Id',
				'PricebookEntryId'
			};
		}

		public String getFieldId() {
			return 'Id';
		}
		public String getFieldExternal() {
			return 'ExternalId__c';
		}
		public String getParentId() {
			return 'OrderId';
		}
		public String getParentKey() {
			return this.orderExternalId;
		}
	}

	global virtual class Response {
		public String salesforceId;
		public String externalId;
		public String sobjectType;
		public Boolean hasError;
		public String errorMessage;

		public void success(String salesforceId, String externalId, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= false;
		}

		public void error(String externalId, String errorMessage, String sobjectType){
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}

		public void error(String salesforceId, String externalId, String errorMessage, String sobjectType){
			this.salesforceId	= salesforceId;
			this.externalId		= externalId;
			this.sobjectType	= sobjectType;
			this.hasError		= true;
			this.errorMessage	= errorMessage;
		}
	}
	global class ResponseParent extends Response {
		public List<DataIntegrationFields.Response> items;
	}
	public class RequestResponseObject {
    // Response object, in case the callout was successful.
    public HttpResponse response;
    // Boolean that determines if there is an exception or a HttpResponse.
    public Boolean success;
    // Exception object, in case there is any.
    public Exception exceptionObject;

    public RequestResponseObject(HttpResponse response) {
      this.success = true;
      this.response = response;
      this.exceptionObject = null;
    }

    public RequestResponseObject(Exception ex) {
      this.success = false;
      this.response = null;
      this.exceptionObject = ex;
    }
  }
  public class CalloutResponse {
    public Boolean hasError;
    public String errorMessage;

    public ResponseParametersWrapper parsedResponse;
    public List<ResponseParametersWrapper> parsedResponses;

    public CalloutResponse(String errorMessage) {
      this.hasError = true;
      this.errorMessage = errorMessage;
    }
    public CalloutResponse(
      ResponseParametersWrapper response,
      Boolean hasError
    ) {
      this.hasError = hasError;
      this.errorMessage = '';
      this.parsedResponse = response;
    }
    public CalloutResponse(
      List<ResponseParametersWrapper> responseList,
      Boolean hasError
    ) {
      this.hasError = hasError;
      this.errorMessage = '';
      this.parsedResponses = responseList;
    }
  }

  public class ResponseParametersWrapper {
    public Boolean hasError;
    public String errorMessage;
    public String salesforceId;
    public String externalId;
    public String sobjectType;

    public List<ResponseParametersWrapper> items;
  }

  public class RequestList {
    public List<OrderParameters> orderRequestList;

    public RequestList(
      List<DataIntegrationFields.OrderParameters> orderRequestList
    ) {
      this.orderRequestList = orderRequestList;
    }
  }
  public class Request {
    public OrderParameters orderRequest;

    public Request(DataIntegrationFields.OrderParameters orderRequest) {
      this.orderRequest = orderRequest;
    }
  }

  public class OrderParameters {
    public String externalId;
    public String status;
    public Date effectiveDate;
    public String accountExternalId;
    public String pricebook2ExternalId;
    public String shippingType;
    public String addressName;
    public String distributionCenterName;
    public Date deliveryDate;
    public String paymentTermsName;
    public String contractExternalId;

    public OrderItemParameters[] orderItemList;

    public OrderParameters(Order order) {
      this.externalId             = order.ExternalId__c;
      this.status                 = 'new';
      this.effectiveDate          = order.EffectiveDate;
      this.accountExternalId      = order.Account?.ExternalId__c;
      this.pricebook2ExternalId   = order.Pricebook2?.ExternalId__c;
      this.shippingType           = order.FreightType__c;
      this.addressName            = order.Address__r?.PostalCode__c;
      this.distributionCenterName = order.DistributionCenter__r?.Name;
      this.deliveryDate           = order.DeliveryDate__c;
      this.paymentTermsName       = order.PaymentTerm__r?.Name;
      this.contractExternalId     = 'AGRO_EXTERNAL_INTEGRATION_CONTRACT';

      this.orderItemList = new List<OrderItemParameters>();

      for (OrderItem orderItem : Order.OrderItems)
        orderItemList.add(new OrderItemParameters(orderItem));
    }
  }
  public class OrderItemParameters {
    public String id;
    public String externalId;
    public Decimal quantity;
    public String orderExternalId;
    public Decimal unitPrice;
    public Decimal sellingPrice;
    public Decimal productionCost;
    public String productExternalId;
    public String pricebookEntryExternalId;

    public OrderItemParameters(OrderItem orderItem) {
      this.externalId = orderItem.ExternalId__c;
      this.quantity = orderItem.Quantity;
      this.unitPrice = orderItem.UnitPrice;
      this.orderExternalId = orderItem.Order.ExternalId__c;
      this.pricebookEntryExternalId = orderItem.PricebookEntry.ExternalId__c;
      this.sellingPrice = orderItem.UnitPrice;
      this.productionCost = orderItem.ProductionCost__c;
    }
  }

}