# Desafio Pricing — Contexto para Claude Code

## O que é este projeto

Projeto Salesforce Apex de um motor de pricing que calcula **Frete**, **Margem** e **Imposto** para `OrderItem`s. Usa padrão **Facade + Strategy** implementado em inglês (migração PT→EN concluída).

---

## Arquitetura do Motor de Pricing

### Fluxo principal

```
OrderItem (trigger after insert/update)
    └─→ OrderItemHandler
            └─→ PricingFacade.calcularPricing(List<OrderItem>)
                    ├─ Query Order (com Account, Address, CD)
                    ├─ Query Product2 (com ProductHierarchy)
                    ├─ Monta PricingContext (DTO central com 3 "malinhas")
                    └─ Para cada IPricingEngine:
                        ├─ FreightPricingEngine  → FreightSelector → FreightStrategy (Product|Hierarchy)
                        ├─ MarginPricingEngine   → MarginSelector  → MarginStrategy  (Product|Hierarchy)
                        └─ TaxPricingEngine      → TaxSelector     → ProductTaxStrategy
```

### Total de queries por ciclo: 5 (bulk-safe, sem N+1)
- 1× Order (com relationships Account + Address)
- 1× Product2
- 1× Freight__c (FreightSelector)
- 1× Margin__c (MarginSelector)
- 1× Tax__c (TaxSelector)

---

## Estrutura de Classes

```
force-app/main/default/classes/
├── motorBusca/
│   ├── PricingFacade.cls          — orquestrador, entra com List<OrderItem>
│   ├── PricingContext.cls         — DTO central com BulkFreightContext, BulkMarginContext, BulkTaxContext
│   ├── IPricingEngine.cls         — interface: calculatePrice(items, context)
│   ├── FreightPricingEngine.cls   — engine de frete
│   ├── MarginPricingEngine.cls    — engine de margem
│   ├── TaxPricingEngine.cls       — engine de imposto
│   ├── freight/
│   │   ├── FreightStrategy.cls / FreightEngine.cls / FreightContext.cls
│   │   ├── ProductFreightStrategy.cls   — match por Produto
│   │   └── HierarchyFreightStrategy.cls — match por Hierarquia (fallback)
│   ├── margin/
│   │   ├── MarginStrategy.cls / MarginEngine.cls / MarginContext.cls
│   │   ├── ProductMarginStrategy.cls
│   │   └── HierarchyMarginStrategy.cls
│   └── tax/
│       ├── TaxStrategy.cls / TaxEngine.cls / TaxContext.cls
│       └── ProductTaxStrategy.cls
│
├── freightTriggerClass/
│   ├── FreightSelector.cls   — query Freight__c com chave composta (alvoId + geoId)
│   ├── FreightService.cls    — validação de duplicidade (otimizada: filtra por CD + Produto)
│   ├── FreightHandler.cls
│   └── FreightTriggerHandler.cls
│
├── marginTriggerClass/
│   ├── MarginSelector.cls    — query Margin__c com chave composta (produto + conta + CD + geo)
│   ├── MarginService.cls     — validação de duplicidade (otimizada: filtra por Produto + Conta)
│   ├── MarginHandler.cls
│   └── MarginTriggerHandler.cls
│
├── taxTriggerClass/
│   ├── TaxSelector.cls       — query Tax__c com chave composta (produto + CD + estado)
│   ├── TaxService.cls        — validação de duplicidade (otimizada: filtra por Produto + CD)
│   ├── TaxHandler.cls
│   └── TaxTriggerHandler.cls
│
├── produtoPedidoTriggerClass/
│   ├── OrderItemHandler.cls  — handler principal, chama PricingFacade
│   └── TriggerHandler.cls    — framework base de trigger
│
├── orderTriggerClass/
│   ├── OrderHandler.cls / OrderService.cls / OrderTriggerHandler.cls
│
├── productClass/
│   └── ProductHandler.cls / ProductService.cls / ProductTriggerHandler.cls
│
└── rest-api/
    └── IntegrationInboundOrder.cls  — integração inbound de pedidos
```

---

## Objetos Customizados Principais

| Objeto | Finalidade |
|--------|-----------|
| `Freight__c` | Regras de custo de frete (Produto/Hierarquia × CD × Geo) |
| `Margin__c` | Regras de margem (Produto/Hierarquia × Conta/Grupo × CD × Geo) |
| `Tax__c` | Regras de imposto (Produto × CD × Estado) |
| `Order` | Pedido (com `DistributionCenter__c`, `Address__r`) |
| `OrderItem` | Item do pedido — ponto de entrada do pricing |
| `Product2` | Produto (com `ProductHierarchy__c`, `ProductionCost__c`) |

### Campos importantes
- `Status__c = 'Approved'` — todas as regras (Freight, Margin, Tax) só são buscadas se Approved
- `DistributionCenter__c` — lookup em Order e nas regras
- `ProductHierarchy__c` — lookup em Product2, usado como fallback nas regras
- `AccountGroup__c` — lookup em Account, usado como fallback de conta em Margin

---

## Padrão de Chaves Compostas nos Selectors

**FreightSelector:** `String.valueOf(alvoId) + String.valueOf(geoId)`
- `alvoId` = Product__c ou ProductHierarchy__c (preferência produto)
- `geoId` = City__c → State__c → Country__c → DistributionCenter__c (mais específico primeiro)

**MarginSelector:** `pAlvo + cAlvo [+ CD] [+ geoAlvo]`
- `pAlvo` = Product__c ou ProductHierarchy__c
- `cAlvo` = Account__c ou AccountGroup__c
- CD e geo são opcionais (mais específico tem prioridade)

**TaxSelector:** `pAlvo + CD + state`

---

## Otimizações de Query nos Services (implementadas)

Os Services de validação de duplicidade extraem IDs do lote de entrada **antes** da query, evitando full table scan:

```apex
// FreightService — query restrita a CD + Produto/Hierarquia do lote
WHERE Status__c = 'Approved'
AND Id NOT IN :idsExistentesNoLote
AND DistributionCenter__c IN :cdsNovos
AND (Product__c IN :produtosNovos OR ProductHierarchy__c IN :hierarquiasNovas)

// MarginService — query restrita a Produto/Hierarquia + Conta/Grupo do lote
WHERE Status__c = 'Approved'
AND (Product__c IN :produtosNovos OR ProductHierarchy__c IN :hierarquiasNovas)
AND (Account__c IN :contasNovas OR AccountGroup__c IN :gruposNovos)

// TaxService — query restrita a Produto + CD do lote
WHERE Status__c = 'Approved'
AND Product__c IN :produtosNovos
AND DistributionCenter__c IN :cdsNovos
```

---

## Bugs Conhecidos / Pendências

| Prioridade | Arquivo | Problema |
|-----------|---------|---------|
| Alta | `FreightSelector.cls` | `locaisIds` é recebido mas **não usado** no WHERE — fallback geográfico pode não restringir corretamente |
| Alta | `MarginSelector.cls` | Não filtra por `DistributionCenter__c` (pode retornar margens de outros CDs — intencional?) |
| Média | `OrderItemHandler.cls` | Sem proteção contra recursão de trigger |
| Baixa | Vários | `System.debug` em excesso — remover antes de prod |

---

## Testes

Localização: `force-app/main/default/classes/force-app-test/`

Cobertura atual: 100% nas classes principais do motor.

Para rodar:
```bash
sfdx force:apex:test:run --testlevel RunLocalTests --outputdir test-results
```

---

## Convenções do Projeto

- Idioma: **inglês** em todo código (migração PT→EN concluída no commit `98590dc`)
- Branch de desenvolvimento: `pricing`
- Sem comentários explicando "o quê" — apenas "por quê" quando não óbvio
- Sem `System.debug` em produção
