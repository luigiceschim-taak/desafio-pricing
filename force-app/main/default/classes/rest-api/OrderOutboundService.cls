public with sharing class OrderOutboundService {

    // ========================================================================
    // 1. MÉTODO PRINCIPAL DE ENVIO (CALLOUT)
    // ========================================================================
    @future(callout=true)
    public static void sendOrderToExternalSystem(Id orderId) {
        // try {
        //     // 1. Busca os dados na sua Org (em português)
        //     Order orderRecord = [SELECT Id, ExternalId__c, Status, EffectiveDate, 
        //                                 Account.ExternalId__c, Pricebook2.ExternalId__c,
        //                                 FreightType__c, Address__r.Name, DistributionCenter__r.Name,
        //                                 DeliveryDate__c, PaymentTerm__c, Contrato__r.ExternalId__c,
        //                                 (SELECT Id, ExternalId__c, PricebookEntry.ExternalId__c,
        //                                         Quantity, UnitPrice, Preco_Venda__c, ProductionCost__c
        //                                  FROM OrderItems)
        //                          FROM Order WHERE Id = :orderId LIMIT 1];

        //     // 2. Instancia o DTO raiz
        //     OrderPayloadDTO dto = new OrderPayloadDTO();

        //     // 3. Mapeia os campos do Pedido (Traduzindo Pt-Br para o JSON esperado)
        //     dto.orderRequest.accountExternalId      = orderRecord.Account.ExternalId__c;
        //     dto.orderRequest.addressName            = orderRecord.Address__r.Name;
        //     dto.orderRequest.paymentTermsName       = orderRecord.PaymentTerm__c;
        //     dto.orderRequest.effectiveDate          = String.valueOf(orderRecord.EffectiveDate);
        //     dto.orderRequest.shippingType           = orderRecord.FreightType__c;
        //     dto.orderRequest.distributionCenterName = orderRecord.DistributionCenter__r.Name;
        //     dto.orderRequest.externalId             = orderRecord.ExternalId__c;
        //     dto.orderRequest.deliveryDate           = String.valueOf(orderRecord.DeliveryDate__c);
        //     dto.orderRequest.pricebook2ExternalId   = orderRecord.Pricebook2.ExternalId__c;
        //     dto.orderRequest.status                 = 'draft'; // Conforme o payload fixo solicitado
            
        //     // Tratamento de segurança caso o Pedido não tenha um Contrato vinculado
        //     dto.orderRequest.contractExternalId = (orderRecord.Contrato__r != null) ? orderRecord.Contrato__r.ExternalId__c : null;

        //     // 4. Mapeia os Itens do Pedido
        //     for (OrderItem itemPt : orderRecord.OrderItems) {
        //         OrderItemDTO itemEn = new OrderItemDTO();
                
        //         itemEn.externalId               = itemPt.ExternalId__c;
        //         itemEn.orderExternalId          = orderRecord.ExternalId__c; 
        //         itemEn.pricebookEntryExternalId = itemPt.PricebookEntry.ExternalId__c;
        //         itemEn.quantity                 = itemPt.Quantity;
        //         itemEn.unitPrice                = itemPt.UnitPrice;
        //         itemEn.sellingPrice             = itemPt.Preco_Venda__c;
        //         itemEn.productionCost           = itemPt.ProductionCost__c;
                
        //         dto.orderRequest.orderItemList.add(itemEn);
        //     }

        //     // 5. Serializa o DTO gerando o JSON limpo e exato (removendo campos nulos se necessário)
        //     String jsonBody = JSON.serialize(dto, true);

        //     // 6. Faz o Callout via Named Credential
        //     HttpRequest req = new HttpRequest();
        //     // Lembre-se de ajustar o path da URL conforme o endpoint correto da Org B
        //     req.setEndpoint('callout:LET_API/services/apexrest/OrderIntegration'); 
        //     req.setMethod('POST');
        //     req.setHeader('Content-Type', 'application/json');
        //     req.setBody(jsonBody);

        //     Http http = new Http();
        //     HttpResponse res = http.send(req);

        //     // 7. Log simples de sucesso/erro (Substitua por seu IntegrationLog__c se necessário)
        //     System.debug('Status Code: ' + res.getStatusCode());
        //     System.debug('Response Body: ' + res.getBody());

        // } catch (Exception e) {
        //     System.debug('Erro no Callout: ' + e.getMessage() + ' na linha ' + e.getLineNumber());
        // }
    }

    // ========================================================================
    // 2. CLASSES DTO INTERNAS (Estrutura do JSON do Lele)
    // ========================================================================
    
    // Classe Wrapper Raiz
    public class OrderPayloadDTO {
        public OrderRequestDTO orderRequest;

        public OrderPayloadDTO() {
            this.orderRequest = new OrderRequestDTO();
        }
    }

    // Classe Wrapper do Pedido
    public class OrderRequestDTO {
        public String accountExternalId;
        public String addressName;
        public String paymentTermsName;
        public String effectiveDate;
        public String shippingType;
        public String distributionCenterName;
        public String externalId;
        public String deliveryDate;
        public String pricebook2ExternalId;
        public String status;
        public String contractExternalId;
        public List<OrderItemDTO> orderItemList;

        public OrderRequestDTO() {
            this.orderItemList = new List<OrderItemDTO>();
        }
    }

    // Classe Wrapper dos Itens
    public class OrderItemDTO {
        public String externalId;
        public String orderExternalId;
        public String pricebookEntryExternalId;
        public Decimal quantity;
        public Decimal unitPrice;
        public Decimal sellingPrice;
        public Decimal productionCost;
    }
}