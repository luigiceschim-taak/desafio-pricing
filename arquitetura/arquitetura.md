# Arquitetura — Desafio Pricing

> Última atualização: 2026-05-14
> Branch: pricing

---

## Visão Geral

Sistema de precificação automática em Salesforce Apex. Quando um `OrderItem` é inserido ou atualizado, o sistema calcula automaticamente **Frete**, **Margem** e **Imposto** com base em regras cadastradas, resolvendo a hierarquia mais específica para a mais genérica (Produto → Hierarquia de Produto; Cidade → Estado → País).

---

## Modelo de Dados

```
Country__c
  └── State__c
        └── City__c
              └── Address__c
                    └── Order ──────────────── DistributionCenter__c
                          └── OrderItem
                                └── Product2
                                      └── ProductHierarchy__c

Account ──── AccountGroup__c
  └── Order

Freight__c  (regra: Produto/Hierarquia + CD + Localidade)
Margin__c   (regra: Produto/Hierarquia + Conta/GrupoConta + CD + Localidade)
Tax__c      (regra: Produto + CD + Estado)
```

### Objetos Customizados

| Objeto | Propósito |
|--------|-----------|
| `Country__c` | País |
| `State__c` | Estado (lookup → Country__c) |
| `City__c` | Cidade (lookup → State__c) |
| `Address__c` | Endereço (lookup → City__c) |
| `DistributionCenter__c` | Centro de Distribuição |
| `AccountGroup__c` | Grupo/Hierarquia de Conta |
| `ProductHierarchy__c` | Hierarquia de Produto |
| `PaymentTerm__c` | Condição de Pagamento |
| `Freight__c` | Tabela de regras de Frete |
| `Margin__c` | Tabela de regras de Margem |
| `Tax__c` | Tabela de regras de Imposto |
| `IntegrationLog__c` | Log de integrações REST |

### Campos calculados em `OrderItem`

| Campo | Engine responsável |
|-------|--------------------|
| `FreightCost__c` | `FreightPricingEngine` |
| `MarginPercentage__c` | `MarginPricingEngine` |
| `TaxPercentage__c` | `TaxPricingEngine` |
| `ProductionCost__c` | `OrderItemHandler.custoDeProd()` |

---

## Camadas da Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│  TRIGGER                                                        │
│  OrderItemTrigger · FreightTrigger · MarginTrigger · TaxTrigger │
│  OrderTrigger · ProductTrigger                                  │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  HANDLER  (TriggerHandler — base virtual)                       │
│  OrderItemHandler · FreightHandler · MarginHandler              │
│  TaxHandler · OrderHandler · ProductHandler                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │ beforeInsert / beforeUpdate
┌──────────────────────────▼──────────────────────────────────────┐
│  PRICING FACADE  (único entry point de precificação)            │
│  PricingFacade.calcularPricing(List<OrderItem>)                 │
│  ├── 1x Query Order  (Account, CD, Address geográfico completo) │
│  ├── 1x Query Product2 (ProductHierarchy__c)                    │
│  └── generateGeneralContext() → PricingContext (DTO mestre)     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────┐
│  ENGINES  (IPricingEngine)                                      │
│  FreightPricingEngine → MarginPricingEngine → TaxPricingEngine  │
│  Cada engine: chama Selector → instancia Engine → loop items    │
└───────┬──────────────────┬──────────────────────┬───────────────┘
        │                  │                       │
┌───────▼────────┐ ┌───────▼────────┐ ┌───────────▼────────┐
│ SELECTORS      │ │ SELECTORS      │ │ SELECTORS          │
│ FreightSelector│ │ MarginSelector │ │ TaxSelector        │
│ 1 SOQL → Mapa │ │ 1 SOQL → Mapa │ │ 1 SOQL → Mapa     │
└───────┬────────┘ └───────┬────────┘ └───────────┬────────┘
        │                  │                       │
┌───────▼────────┐ ┌───────▼────────┐ ┌───────────▼────────┐
│ ENGINE INTERNO │ │ ENGINE INTERNO │ │ ENGINE INTERNO     │
│ FreightEngine  │ │ MarginEngine   │ │ TaxEngine          │
└───────┬────────┘ └───────┬────────┘ └───────────┬────────┘
        │                  │                       │
┌───────▼────────┐ ┌───────▼────────┐ ┌───────────▼────────┐
│ STRATEGIES     │ │ STRATEGIES     │ │ STRATEGIES         │
│ Product→       │ │ Product→       │ │ ProductTax         │
│ Hierarchy      │ │ Hierarchy      │ │ Strategy           │
└────────────────┘ └────────────────┘ └────────────────────┘
```

---

## Motor de Precificação (detalhado)

### PricingFacade
**Arquivo:** `motorBusca/PricingFacade.cls`

Entry point único. Faz as duas queries base (Order + Product2) uma única vez, monta o `PricingContext` e delega para os engines em sequência.

```
PricingFacade.calcularPricing()
  │
  ├── Query Order: Id, AccountId, Account.AccountGroup__c,
  │               DistributionCenter__c,
  │               Address__r.City__c,
  │               Address__r.City__r.State__c,
  │               Address__r.City__r.State__r.Country__c
  │
  ├── Query Product2: Id, ProductHierarchy__c
  │
  ├── generateGeneralContext() → PricingContext
  │     ├── mapPedidos   (Map<Id, Order>)
  │     ├── mapProdutos  (Map<Id, Product2>)
  │     ├── frete.{produtosIds, hierarquiasIds, cdsIds, locaisIds}
  │     ├── margem.{produtosIds, hierarquiasIds, contasIds, hContasIds, cdsIds, locaisIds}
  │     └── imposto.{produtosIds, cdsIds, locaisIds}
  │
  └── for engine in [FreightPricingEngine, MarginPricingEngine, TaxPricingEngine]:
        engine.calculatePrice(itens, context)
```

### IPricingEngine (interface)
**Arquivo:** `motorBusca/IPricingEngine.cls`

```apex
public interface IPricingEngine {
    void calculatePrice(List<OrderItem> item, PricingContext contexto);
}
```

Para adicionar um novo tipo de pricing (ex: Desconto), basta criar uma classe `implements IPricingEngine` e adicionar na lista da Facade.

---

## Engines de Precificação

### FreightPricingEngine
**Arquivo:** `motorBusca/FreightPricingEngine.cls`

- Chama `FreightSelector.getMapaRegras(produtosIds, hierarquiasIds, locaisIds, cdsIds)`
- Cria `FreightContext` por item (pId, hId, cdId, cidId, estId, paiId)
- Usa `FreightEngine` com estratégias: **ProductFreightStrategy** → **HierarchyFreightStrategy**
- Resolução geográfica: **Cidade → Estado → País**
- Popula: `item.FreightCost__c`

### MarginPricingEngine
**Arquivo:** `motorBusca/MarginPricingEngine.cls`

- Chama `MarginSelector.getMapaRegras(produtosIds, hierarquiasIds, locaisIds, cdsIds, contasIds, gruposContasIds)`
- Cria `MarginContext` por item (pId, hId, cntId, hCntId, cdId, cidId, estId, paiId)
- Usa `MarginEngine` com estratégias: **ProductMarginStrategy** → **HierarchyMarginStrategy**
- Cada estratégia tenta: Conta → GrupoConta; resolução geográfica: Cidade → Estado → País
- Popula: `item.MarginPercentage__c`

### TaxPricingEngine
**Arquivo:** `motorBusca/TaxPricingEngine.cls`

- Chama `TaxSelector.getMapaRegras(produtosIds, locaisIds, cdsIds)`
- Cria `TaxContext` por item (pId, cdId, estId)
- Usa `TaxEngine` com estratégia única: **ProductTaxStrategy**
- Chave única: Produto + CD + Estado (sem fallback geográfico)
- Popula: `item.TaxPercentage__c`

---

## Hierarquia de Busca por Engine

```
FRETE (FreightEngine)
  1. Produto  + Cidade
  2. Produto  + Estado
  3. Produto  + País
  4. Hierarquia + Cidade
  5. Hierarquia + Estado
  6. Hierarquia + País

MARGEM (MarginEngine)
  1. Produto    + Conta         + CD + Cidade
  2. Produto    + Conta         + CD + Estado
  3. Produto    + Conta         + CD + País
  4. Produto    + GrupoConta    + CD + Cidade
  5. Produto    + GrupoConta    + CD + Estado
  6. Produto    + GrupoConta    + CD + País
  7. Hierarquia + Conta         + CD + Cidade
  8. Hierarquia + Conta         + CD + Estado
  9. Hierarquia + Conta         + CD + País
 10. Hierarquia + GrupoConta    + CD + Cidade
 11. Hierarquia + GrupoConta    + CD + Estado
 12. Hierarquia + GrupoConta    + CD + País

IMPOSTO (TaxEngine)
  1. Produto + CD + Estado  (única tentativa)
```

---

## Chaves Compostas dos Mapas

Os Selectors montam um `Map<String, SObject>` com chaves construídas por concatenação de IDs (18 chars). As Strategies buscam usando a mesma lógica.

| Engine | Chave do Selector | Chave da Strategy |
|--------|-------------------|-------------------|
| Freight | `alvoId + geoId` | `ctx.pId/hId + ctx.cidId/estId/paiId` |
| Margin | `pAlvo + cAlvo + [cdId] + [geoId]` | `pAlvo + cAlvo + ctx.cdId + ctx.cidId/estId/paiId` |
| Tax | `pId + cdId + estId` | `ctx.pId + ctx.cdId + ctx.estId` |

---

## Triggers e Handlers

| Trigger | Objeto | Eventos | Handler |
|---------|--------|---------|---------|
| `OrderItemTrigger` | OrderItem | before insert, after insert, before update | `OrderItemHandler` |
| `OrderTrigger` | Order | before update, after update | `OrderHandler` |
| `FreightTrigger` | Freight__c | before insert, before update | `FreightHandler` |
| `MarginTrigger` | Margin__c | before insert, before update | `MarginHandler` |
| `TaxTrigger` | Tax__c | before insert, before update | `TaxHandler` |
| `ProductTrigger` | Product2 | after insert | `ProductHandler` |

### TriggerHandler (base)
**Arquivo:** `produtoPedidoTriggerClass/TriggerHandler.cls`

Classe virtual base. Todos os handlers herdam dela e sobrescrevem `beforeInsert()`, `beforeUpdate()`, `afterInsert()` conforme necessário.

### OrderItemHandler
**Arquivo:** `produtoPedidoTriggerClass/OrderItemHandler.cls`

```
beforeInsert → PricingFacade.calcularPricing()  (Frete + Margem + Imposto)
             → custoDeProd()                     (busca ProductionCost__c)

beforeUpdate → validarStatusPedido()             (bloqueia se Order = Ativo)
             → PricingFacade.calcularPricing()

afterInsert  → mesclarItensExistentes()          (unifica duplicatas do mesmo produto no pedido)
```

### OrderHandler / OrderService
**Arquivo:** `orderTriggerClass/`

`afterUpdate`: quando o endereço ou CD do pedido muda, recalcula o pricing de todos os `OrderItem` do pedido chamando `PricingFacade.calcularPricing()`.

### FreightHandler / MarginHandler / TaxHandler
Chamam seus respectivos Services para **validar duplicidade** antes de inserir/atualizar regras de precificação.

---

## Serviços de Validação

| Service | Responsabilidade |
|---------|-----------------|
| `FreightService` | Impede inserção de regras de Frete duplicadas (mesma combinação Produto/Hierarquia + CD + Localidade) |
| `MarginService` | Impede inserção de regras de Margem duplicadas |
| `TaxService` | Impede inserção de regras de Imposto duplicadas + valida valor positivo |

---

## REST API (Integração)

**Pasta:** `rest-api/`

| Classe | Responsabilidade |
|--------|-----------------|
| `IntegrationInboundOrder` | Endpoint REST — recebe pedidos externos em lote |
| `IntegrationInboundOneOrder` | Endpoint REST — recebe um pedido individual |
| `OrderOutboundService` | Envia pedidos para sistemas externos |
| `FactoryDataIntegration` | Factory que mapeia o payload externo para SObjects Salesforce |
| `DataIntegrationFields` | DTO com os campos do payload de integração |
| `IntegrationUtils` | Utilitários de validação e parsing |
| `IntegrationLog` | Persiste logs de integração em `IntegrationLog__c` |

---

## Testes

**Pasta:** `force-app-test/`

| Arquivo de Teste | O que cobre |
|-----------------|-------------|
| `OrderItemTest` | Insert/Update de OrderItem com pricing completo |
| `OrderTest` | Recálculo de pricing quando Order muda endereço/CD |
| `FreightTest` / `FreightSelectorTest` | Lookup de frete por produto e hierarquia |
| `MarginTest` / `MarginSelectorTest` | Lookup de margem com hierarquia de conta/produto |
| `TaxTest` / `TaxSelectorTest` / `TaxServiceTest` | Lookup e validação de imposto |
| `AccountTest`, `AccountGroupTest`, etc. | CRUD dos objetos de suporte |
| `TestFactorySObject` / `TemplateDefaultFields` | Factory de dados de teste |

---

## SOQL Budget por Operação

| Operação | Queries |
|----------|---------|
| Insert OrderItem (before) | 2 base (Order + Product2) + 3 selectors (Freight + Margin + Tax) + 1 custo prod = **6** |
| Update OrderItem (before) | 2 base + 3 selectors + 1 validação status = **6** |
| Update Order com mudança de endereço/CD | 1 query OrderItem + 2 base + 3 selectors = **6** |

---

## Como Adicionar um Novo Engine de Pricing

1. Criar `MinhaRegraContext.cls` em `motorBusca/minhaRegra/`
2. Criar `MinhaRegraStrategy.cls` (abstract) + estratégias concretas
3. Criar `MinhaRegraEngine.cls`
4. Criar `MinhaRegraSelector.cls` em `minhaRegraTriggerClass/`
5. Adicionar `BulkMinhaRegraContext` em `PricingContext.cls`
6. Popular os IDs em `PricingFacade.generateGeneralContext()`
7. Criar `MinhaRegraPricingEngine.cls implements IPricingEngine`
8. Adicionar à lista em `PricingFacade.calcularPricing()`:
   ```apex
   new MinhaRegraPricingEngine()
   ```

---

## Estrutura de Pastas

```
force-app/main/default/
├── triggers/
│   ├── orderItemTrigger/      OrderItemTrigger
│   ├── orderTrigger/          OrderTrigger
│   ├── freightTrigger/        FreightTrigger
│   ├── marginTrigger/         MarginTrigger
│   ├── taxTrigger/            TaxTrigger
│   └── productTrigger/        ProductTrigger
│
├── classes/
│   ├── produtoPedidoTriggerClass/   TriggerHandler (base), OrderItemHandler
│   ├── orderTriggerClass/           OrderHandler, OrderService, OrderTriggerHandler
│   ├── productClass/                ProductHandler, ProductService, ProductTriggerHandler
│   ├── freightTriggerClass/         FreightHandler, FreightSelector, FreightService, FreightTriggerHandler
│   ├── marginTriggerClass/          MarginHandler, MarginSelector, MarginService, MarginTriggerHandler
│   ├── taxTriggerClass/             TaxHandler, TaxSelector, TaxService, TaxTriggerHandler
│   ├── motorBusca/
│   │   ├── IPricingEngine           Interface
│   │   ├── PricingContext           DTO mestre + inner classes BulkXxxContext
│   │   ├── PricingFacade            Entry point de precificação
│   │   ├── FreightPricingEngine
│   │   ├── MarginPricingEngine
│   │   ├── TaxPricingEngine
│   │   ├── freight/    FreightContext, FreightEngine, FreightStrategy, Product/HierarchyFreightStrategy
│   │   ├── margin/     MarginContext, MarginEngine, MarginStrategy, Product/HierarchyMarginStrategy
│   │   └── tax/        TaxContext, TaxEngine, TaxStrategy, ProductTaxStrategy
│   ├── rest-api/                    Integração REST inbound/outbound
│   └── force-app-test/              Todos os testes
│
└── objects/
    Account, AccountGroup__c, Address__c, City__c, Country__c,
    DistributionCenter__c, Freight__c, IntegrationLog__c, Margin__c,
    Order, OrderItem, PaymentTerm__c, Product2, ProductHierarchy__c,
    State__c, Tax__c
```
