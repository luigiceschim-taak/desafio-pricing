@isTest
private class GoalAttributionFacadeTest {

    private static final String FAMILY = 'Hardware';
    private static final String PAYMENT = 'Boleto';

    // Mock do único repositório que dependeria de Orders/OrderItems reais.
    private class MockOrderItemRepository implements IOrderItemRepository {
        private List<OrderItem_DTO> items;
        MockOrderItemRepository(List<OrderItem_DTO> items) { this.items = items; }
        public List<OrderItem_DTO> findByOwners(Set<Id> ownerIds) { return items; }
    }

    @TestSetup
    static void setup() {
        // Ativa a Tabela de Preços padrão para o contexto de teste (validação do ProductService).
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        ProductHierarchy__c hierarchy = new ProductHierarchy__c(Name = 'Hierarquia Teste');
        insert hierarchy;

        Product2 prod = new Product2(
            Name = 'Produto Teste',
            IsActive = true,
            ExternalId__c = 'EXT-PROD-001',
            ProductHierarchy__c = hierarchy.Id,
            ProductionCost__c = 10
        );
        insert prod;

        Product_Family__c family = new Product_Family__c(Name = FAMILY);
        insert family;

        Goal_Condition_Payment__c payment = new Goal_Condition_Payment__c(Name = PAYMENT);
        insert payment;

        Goal__c goal = new Goal__c(
            Name = 'Meta 2026',
            Seller__c = UserInfo.getUserId(),
            Year__c = 2026
        );
        insert goal;

        Map<String, Id> rt = new Map<String, Id>();
        for (RecordType r : [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType = 'GoalItem__c']) {
            rt.put(r.DeveloperName, r.Id);
        }

        insert new List<GoalItem__c>{
            new GoalItem__c(Name = 'Item Produto', Goal__c = goal.Id,
                RecordTypeId = rt.get('Product'), Goal_Product__c = prod.Id, Goal_Amount__c = 1000),
            new GoalItem__c(Name = 'Item Familia', Goal__c = goal.Id,
                RecordTypeId = rt.get('Product_Family'), Product_Family__c = family.Id, Goal_Amount__c = 1000),
            new GoalItem__c(Name = 'Item Pagamento', Goal__c = goal.Id,
                RecordTypeId = rt.get('Payment_Condition'), Goal_Condition_Payment__c = payment.Id, Goal_Amount__c = 1000),
            new GoalItem__c(Name = 'Item Performance', Goal__c = goal.Id,
                RecordTypeId = rt.get('Performance'), Goal_Amount__c = 1000)
        };
    }

    private static OrderItem_DTO orderItem(Id productId, String status, Decimal amount) {
        OrderItem_DTO dto = new OrderItem_DTO();
        dto.ownerId = UserInfo.getUserId();
        dto.productId = productId;
        dto.productFamily = FAMILY;
        dto.paymentCondition = PAYMENT;
        dto.orderStatus = status;
        dto.amount = amount;
        return dto;
    }

    @isTest
    static void process_recalculatesAllGoalItems() {
        Id prodId = [SELECT Id FROM Product2 LIMIT 1].Id;

        List<OrderItem_DTO> mockItems = new List<OrderItem_DTO>{
            orderItem(prodId, 'New', 100),
            orderItem(prodId, 'PendingApproval', 200),
            orderItem(prodId, 'Approved', 300)
        };

        GoalAttributionFacade facade = new GoalAttributionFacade(
            new GoalRepository(),
            new GoalItemRepository(),
            new MockOrderItemRepository(mockItems),
            new GoalMatchingEngine(new GoalMatchingStrategyFactory()),
            new GoalAttributionCalculator()
        );

        List<OrderStatusChange> changes = new List<OrderStatusChange>{
            new OrderStatusChange(null, UserInfo.getUserId(), 'New', 'PendingApproval')
        };

        Test.startTest();
        facade.process(changes);
        Test.stopTest();

        // Os 4 Goal Items casam todos os 3 itens mockados → mesmos valores.
        List<GoalItem__c> items = [
            SELECT Projected_Amount__c, Negotiated_Value__c, Realized_Value__c
            FROM GoalItem__c
        ];
        System.assertEquals(4, items.size(), 'Todos os Goal Items devem ser recalculados');
        for (GoalItem__c gi : items) {
            // Projected = New (100) + PendingApproval (200); PendingApproval conta também no Negotiated.
            System.assertEquals(300, gi.Projected_Amount__c, 'Projected = New + PendingApproval');
            System.assertEquals(200, gi.Negotiated_Value__c, 'Negotiated = PendingApproval');
            System.assertEquals(300, gi.Realized_Value__c, 'Realized = Approved (mock não tem Integrated/IntegrationError)');
        }
    }

    @isTest
    static void process_noMatchingOrderItems_zeroesValues() {
        GoalAttributionFacade facade = new GoalAttributionFacade(
            new GoalRepository(),
            new GoalItemRepository(),
            new MockOrderItemRepository(new List<OrderItem_DTO>()),
            new GoalMatchingEngine(new GoalMatchingStrategyFactory()),
            new GoalAttributionCalculator()
        );

        Test.startTest();
        facade.process(new List<OrderStatusChange>{
            new OrderStatusChange(null, UserInfo.getUserId(), 'New', 'PendingApproval')
        });
        Test.stopTest();

        for (GoalItem__c gi : [SELECT Projected_Amount__c, Negotiated_Value__c, Realized_Value__c FROM GoalItem__c]) {
            System.assertEquals(0, gi.Projected_Amount__c, 'Sem pedidos, projected zerado');
            System.assertEquals(0, gi.Negotiated_Value__c, 'Sem pedidos, negotiated zerado');
            System.assertEquals(0, gi.Realized_Value__c, 'Sem pedidos, realized zerado');
        }
    }

    @isTest
    static void process_emptyChanges_doesNothing() {
        Test.startTest();
        new GoalAttributionFacade().process(new List<OrderStatusChange>());
        Test.stopTest();
        System.assert(true, 'Lista vazia não deve lançar exceção');
    }

    @isTest
    static void run_detectsStatusChange() {
        // Exercita o filtro de mudança de status e o caminho do trigger.
        Id fakeOrderId = TestIdFactory.generate(Order.SObjectType);
        List<Order> newOrders = new List<Order>{
            new Order(Id = fakeOrderId, OwnerId = UserInfo.getUserId(), Status = 'PendingApproval')
        };
        Map<Id, Order> oldOrders = new Map<Id, Order>{
            fakeOrderId => new Order(Id = fakeOrderId, OwnerId = UserInfo.getUserId(), Status = 'New')
        };

        Test.startTest();
        GoalAttributionFacade.run(newOrders, oldOrders);
        Test.stopTest();

        // Sem OrderItems reais, todos os Goal Items são zerados pelo recálculo.
        for (GoalItem__c gi : [SELECT Realized_Value__c FROM GoalItem__c]) {
            System.assertEquals(0, gi.Realized_Value__c, 'Recálculo sem pedidos zera o realizado');
        }
    }
}
