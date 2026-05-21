// ---- Seed data from pricingOrg ----

Account acc = new Account(Name='Agro External Integration Account', BillingCity='Sao Paulo', BillingCountry='Brazil');
insert acc;

Product2 prod1 = new Product2(Name='Agro External Integration Product 001', IsActive=true);
Product2 prod2 = new Product2(Name='Agro External Integration Product 002', IsActive=true);
insert new List<Product2>{ prod1, prod2 };


Id stdPb = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1].Id;

PricebookEntry prod1pbe = new PricebookEntry(Pricebook2Id=stdPb, Product2Id=prod1.Id, UnitPrice=1000000, IsActive=true);
PricebookEntry prod2pbe = new PricebookEntry(Pricebook2Id=stdPb, Product2Id=prod2.Id, UnitPrice=1000000, IsActive=true);
insert new List<PricebookEntry>{ prod1pbe, prod2pbe };

Order ord1 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord1;
OrderItem item1_1 = new OrderItem(OrderId=ord1.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100000, Quantity=1, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0001');
OrderItem item1_2 = new OrderItem(OrderId=ord1.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=100000, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=80, ExternalId__c='OI-SEED-0002');

Order ord2 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord2;
OrderItem item2_1 = new OrderItem(OrderId=ord2.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=1000000, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=80, ExternalId__c='OI-SEED-0003');
OrderItem item2_2 = new OrderItem(OrderId=ord2.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=1000000, Quantity=2, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=40, ExternalId__c='OI-SEED-0004');

Order ord3 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-14'));
insert ord3;
OrderItem item3_1 = new OrderItem(OrderId=ord3.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=1000, Quantity=45, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0005');

Order ord4 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord4;
OrderItem item4_1 = new OrderItem(OrderId=ord4.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=100, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0006');

Order ord5 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord5;
OrderItem item5_1 = new OrderItem(OrderId=ord5.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=1000, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0007');

Order ord6 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord6;
OrderItem item6_1 = new OrderItem(OrderId=ord6.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=150, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=80, ExternalId__c='OI-SEED-0008');
OrderItem item6_2 = new OrderItem(OrderId=ord6.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=10, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=40, ExternalId__c='OI-SEED-0009');

Order ord7 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord7;
OrderItem item7_1 = new OrderItem(OrderId=ord7.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=6000, Quantity=4, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0010');

Order ord8 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord8;
OrderItem item8_1 = new OrderItem(OrderId=ord8.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=150, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=80, ExternalId__c='OI-SEED-0011');
OrderItem item8_2 = new OrderItem(OrderId=ord8.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=1, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=40, ExternalId__c='OI-SEED-0012');

Order ord9 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord9;
OrderItem item9_1 = new OrderItem(OrderId=ord9.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=1000, Quantity=15, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0013');

Order ord10 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord10;
OrderItem item10_1 = new OrderItem(OrderId=ord10.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=150, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=80, ExternalId__c='OI-SEED-0014');
OrderItem item10_2 = new OrderItem(OrderId=ord10.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=1, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=40, ExternalId__c='OI-SEED-0015');

Order ord11 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord11;
OrderItem item11_1 = new OrderItem(OrderId=ord11.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=150, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0016');
OrderItem item11_2 = new OrderItem(OrderId=ord11.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=1, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0017');

Order ord12 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord12;
OrderItem item12_1 = new OrderItem(OrderId=ord12.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=104, Quantity=1, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0018');
OrderItem item12_2 = new OrderItem(OrderId=ord12.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=150, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=80, ExternalId__c='OI-SEED-0019');

Order ord13 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord13;
OrderItem item13_1 = new OrderItem(OrderId=ord13.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=101, Quantity=3, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0020');

Order ord14 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord14;
OrderItem item14_1 = new OrderItem(OrderId=ord14.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=350, Quantity=3, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=260, ExternalId__c='OI-SEED-0021');

Order ord15 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord15;
OrderItem item15_1 = new OrderItem(OrderId=ord15.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=13, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0022');

Order ord16 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord16;
OrderItem item16_1 = new OrderItem(OrderId=ord16.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=1000000, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0023');
OrderItem item16_2 = new OrderItem(OrderId=ord16.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=1000000, Quantity=2, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0024');

Order ord17 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-12-30'));
insert ord17;
OrderItem item17_1 = new OrderItem(OrderId=ord17.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=150, Quantity=5, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0025');
OrderItem item17_2 = new OrderItem(OrderId=ord17.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=1, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0026');

Order ord18 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord18;
OrderItem item18_1 = new OrderItem(OrderId=ord18.Id, PricebookEntryId=prod2pbe.Id, Product2Id=prod2.Id, UnitPrice=10000, Quantity=23, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=500, ExternalId__c='OI-SEED-0027');
OrderItem item18_2 = new OrderItem(OrderId=ord18.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=1800, Quantity=78, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0028');

Order ord19 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2026-05-20'));
insert ord19;
OrderItem item19_1 = new OrderItem(OrderId=ord19.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=9000, Quantity=56, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0029');

Order ord20 = new Order(AccountId=acc.Id, Pricebook2Id=stdPb, Status='Draft', EffectiveDate=Date.valueOf('2027-10-31'));
insert ord20;
OrderItem item20_1 = new OrderItem(OrderId=ord20.Id, PricebookEntryId=prod1pbe.Id, Product2Id=prod1.Id, UnitPrice=100, Quantity=4, FreightCost__c=5, MarginPercentage__c=10, TaxPercentage__c=15, ProductionCost__c=200, ExternalId__c='OI-SEED-0030');

insert new List<OrderItem>{ item1_1, item1_2, item2_1, item2_2, item3_1, item4_1, item5_1, item6_1, item6_2, item7_1, item8_1, item8_2, item9_1, item10_1, item10_2, item11_1, item11_2, item12_1, item12_2, item13_1, item14_1, item15_1, item16_1, item16_2, item17_1, item17_2, item18_1, item18_2, item19_1, item20_1 };

ord1.Status = 'Activated';
ord2.Status = 'Activated';
ord3.Status = 'Activated';
ord4.Status = 'Activated';
ord5.Status = 'Activated';
ord6.Status = 'Activated';
ord7.Status = 'Activated';
ord8.Status = 'Activated';
ord9.Status = 'Activated';
ord10.Status = 'Activated';
ord11.Status = 'Activated';
ord12.Status = 'Activated';
ord13.Status = 'Activated';
ord14.Status = 'Activated';
ord15.Status = 'Activated';
ord16.Status = 'Activated';
ord17.Status = 'Activated';
ord18.Status = 'Activated';
ord19.Status = 'Activated';
ord20.Status = 'Activated';
ord1.Status = 'Activated';
ord2.Status = 'Activated';
ord3.Status = 'Activated';
ord4.Status = 'Activated';
ord5.Status = 'Activated';
ord6.Status = 'Activated';
ord7.Status = 'Activated';
ord8.Status = 'Activated';
ord9.Status = 'Activated';
ord10.Status = 'Activated';
ord11.Status = 'Activated';
ord12.Status = 'Activated';
ord13.Status = 'Activated';
ord14.Status = 'Activated';
ord15.Status = 'Activated';
ord16.Status = 'Activated';
ord17.Status = 'Activated';
ord18.Status = 'Activated';
ord19.Status = 'Activated';
ord20.Status = 'Activated';
update new List<Order>{ ord1, ord2, ord3, ord4, ord5, ord6, ord7, ord8, ord9, ord10, ord11, ord12, ord13, ord14, ord15, ord16, ord17, ord18, ord19, ord20 };

System.debug('Seed complete: ' + 20 + ' orders');