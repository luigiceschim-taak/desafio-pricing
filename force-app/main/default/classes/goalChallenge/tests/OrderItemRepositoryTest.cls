@isTest
private class OrderItemRepositoryTest {

    @TestSetup
    static void setup() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        Country__c country = new Country__c(Name = 'Brasil');
        insert country;

        State__c state = new State__c(Name = 'SP', Country__c = country.Id);
        insert state;

        City__c city = new City__c(Name = 'São Paulo', State__c = state.Id, IBGE_CODE__c = '3550308');
        insert city;

        AccountGroup__c accountGroup = new AccountGroup__c(Name = 'Grupo Teste');
        insert accountGroup;

        Account account = new Account(
            Name = 'Conta Teste',
            AccountGroup__c = accountGroup.Id,
            CNPJ__c = '11222333000181',
            ExternalId__c = 'ACC-001'
        );
        insert account;

        Address__c address = new Address__c(
            Name = 'Endereço Teste',
            Account__c = account.Id,
            City__c = city.Id,
            Neighborhood__c = 'Centro',
            Street__c = 'Rua Teste, 100'
        );
        insert address;

        DistributionCenter__c dc = new DistributionCenter__c(Name = 'CD Teste');
        insert dc;

        ProductHierarchy__c hierarchy = new ProductHierarchy__c(Name = 'Hierarquia Teste');
        insert hierarchy;

        // O trigger de Product2 cria automaticamente as PricebookEntries na tabela padrão.
        Product2 product = new Product2(
            Name = 'Produto Teste',
            IsActive = true,
            ExternalId__c = 'PROD-001',
            ProductHierarchy__c = hierarchy.Id,
            ProductionCost__c = 50
        );
        insert product;

        // Regras de pricing exigidas pelo trigger de OrderItem (Freight/Tax/Margin).
        insert new Freight__c(
            Product__c = product.Id, DistributionCenter__c = dc.Id, City__c = city.Id,
            Status__c = 'Approved', Cost__c = 10
        );
        insert new Tax__c(
            Product__c = product.Id, DistributionCenter__c = dc.Id, State__c = state.Id,
            Status__c = 'Approved', TaxCost__c = 5
        );
        insert new Margin__c(
            Product__c = product.Id, Account__c = account.Id, DistributionCenter__c = dc.Id,
            City__c = city.Id, Status__c = 'Approved', Cost__c = 20
        );

        PaymentTerm__c paymentTerm = new PaymentTerm__c(Name = 'Boleto');
        insert paymentTerm;

        Order order = new Order(
            AccountId = account.Id,
            Address__c = address.Id,
            DistributionCenter__c = dc.Id,
            PaymentTerm__c = paymentTerm.Id,
            Pricebook2Id = pricebookId,
            ExternalId__c = 'ORD-001',
            FreightType__c = 'CIF',
            DeliveryDate__c = Date.today().addDays(5),
            EffectiveDate = Date.today(),
            // Pedido 'New': adicionar item dispara recalc (New->New), que agora é permitido.
            Status = 'New'
        );
        insert order;

        List<PricebookEntry> existing = [
            SELECT Id, UnitPrice FROM PricebookEntry WHERE Product2Id = :product.Id LIMIT 1
        ];
        PricebookEntry pbe;
        if (existing.isEmpty()) {
            pbe = new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = product.Id,
                UnitPrice = 100,
                IsActive = true,
                ExternalId__c = 'PBE-001'
            );
            insert pbe;
        } else {
            pbe = existing[0];
        }

        insert new OrderItem(
            OrderId = order.Id,
            PricebookEntryId = pbe.Id,
            Quantity = 2,
            UnitPrice = pbe.UnitPrice,
            ExternalId__c = 'OI-001'
        );
    }

    @isTest
    static void findByOwners_mapsOrderItemToDto() {
        Set<Id> ownerIds = new Set<Id>{ UserInfo.getUserId() };

        Test.startTest();
        List<OrderItem_DTO> dtos = new OrderItemRepository().findByOwners(ownerIds);
        Test.stopTest();

        System.assertEquals(1, dtos.size(), 'Deve retornar o OrderItem do vendedor');
        OrderItem_DTO dto = dtos[0];
        System.assertEquals(UserInfo.getUserId(), dto.ownerId, 'OwnerId deve refletir o dono do pedido');
        System.assertEquals('Boleto', dto.paymentCondition, 'Condição de pagamento vem de Order.PaymentTerm__r.Name');
        System.assertEquals('New', dto.orderStatus, 'Status do pedido deve ser mapeado');
        System.assertNotEquals(null, dto.productId, 'Produto deve ser mapeado');
        System.assertNotEquals(null, dto.amount, 'Valor (TotalPrice) deve ser mapeado');
    }

    @isTest
    static void findByOwners_noOwners_returnsEmpty() {
        Test.startTest();
        List<OrderItem_DTO> dtos = new OrderItemRepository().findByOwners(new Set<Id>());
        Test.stopTest();

        System.assertEquals(0, dtos.size(), 'Sem owners, retorna lista vazia');
    }

    // Regra: New->New (adicionar item) é livre — provado pelo @TestSetup que insere item num pedido 'New'.
    // Mas SAIR de New para outro status sem nenhum item deve ser bloqueado.
    @isTest
    static void cannotLeaveNewStatusWithoutItems() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Address__c addr = [SELECT Id FROM Address__c LIMIT 1];
        DistributionCenter__c dc = [SELECT Id FROM DistributionCenter__c LIMIT 1];
        PaymentTerm__c pt = [SELECT Id FROM PaymentTerm__c LIMIT 1];

        Order emptyOrder = new Order(
            AccountId = acc.Id, Address__c = addr.Id, DistributionCenter__c = dc.Id,
            PaymentTerm__c = pt.Id, Pricebook2Id = Test.getStandardPricebookId(),
            ExternalId__c = 'ORD-EMPTY', FreightType__c = 'CIF',
            DeliveryDate__c = Date.today().addDays(5), EffectiveDate = Date.today(),
            Status = 'New'
        );
        insert emptyOrder;

        Test.startTest();
        Boolean blocked = false;
        try {
            update new Order(Id = emptyOrder.Id, Status = 'PendingApproval');
        } catch (DmlException e) {
            blocked = e.getMessage().contains('at least one Order Item');
        }
        Test.stopTest();

        System.assert(blocked, 'Sair de New sem itens deve ser bloqueado');
    }
}
