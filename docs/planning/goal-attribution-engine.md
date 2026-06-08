# Motor de Atribuição de Metas — Planejamento de Engenharia

> **Escopo:** Planejamento arquitetural. Nenhuma classe Apex, LWC ou metadado deve ser criado sem este documento como base.  
> **Versão:** 1.1 · Junho 2026  
> **Changelog v1.1:** Record Type como discriminador de Strategy; fluxo de status sem rollback de Approved; recalculo total confirmado; relação N:N pedido ↔ goal items documentada.  
> **Referência de padrões:** Mergulho nos Padrões de Projeto — Alexander Shvets

---

## 1. Visão Geral do Domínio

### 1.1 Objetos envolvidos

```
┌──────────────────────────────────────────────────────────────┐
│                        User (Vendedor)                       │
│                     OwnerId (lookup em ambos)                │
└───────────────────────┬──────────────────┬───────────────────┘
                        │                  │
              ┌─────────▼──────┐  ┌────────▼──────────┐
              │   Goal__c      │  │    Order__c        │
              │   (Meta)       │  │    (Pedido)        │
              │                │  │                    │
              │  Owner__c ─────┼──┼── OwnerId          │
              │  Period__c     │  │  Status__c         │
              │  Target__c     │  │  TotalAmount       │
              │  Status__c     │  └────────┬───────────┘
              └───────┬────────┘           │
                      │ Master-Detail      │ Master-Detail
              ┌───────▼────────┐  ┌────────▼───────────┐
              │ Goal_Item__c   │  │  Order_Item__c     │
              │                │  │                    │
              │ [RecordType] ◄─┼──┼► (campo de match)  │
              │  Negociado__c  │  │  Product2Id        │
              │  Projetado__c  │  │  Product2.Family   │
              │  Realizado__c  │  │  Payment_Cond__c   │
              │  Target__c     │  │  UnitPrice / Qty   │
              └────────────────┘  └────────────────────┘
```

### 1.2 A ligação core: o Vendedor como mediador

O `User` (vendedor) é o eixo central:
- `Order__c.OwnerId` → vendedor dono do pedido
- `Goal__c.Owner__c` → vendedor dono da meta

O engine navega essa ponte: **ao mudar o status de um pedido, busca metas ativas do mesmo vendedor e avalia todos os Goal Items contra todos os Order Items do pedido.**

### 1.3 Record Types de Goal_Item__c como discriminador de Strategy

O tipo de meta não é determinado por um campo picklist, mas pelo **Record Type do Goal_Item__c**. Isso segmenta o objeto no nível do metadado Salesforce (page layouts, campos distintos por tipo), e serve como chave de seleção da Strategy no engine.

| Record Type (DeveloperName) | Campo de correlação em `Order_Item__c` | Semântica |
|---|---|---|
| `Goal_Item_Produto` | `Product2Id` | Meta por produto específico |
| `Goal_Item_Familia` | `Product2.Family` | Meta por família de produtos |
| `Goal_Item_Performance` | Agregado (receita, quantidade) | Meta de performance geral do vendedor no período |
| `Goal_Item_Condicao_Pagamento` | `Payment_Condition__c` | Meta por condição de pagamento |

O `GoalMatchingStrategyFactory` recebe o `RecordType.DeveloperName` e retorna a implementação correta de `IGoalMatchingStrategy`.

---

## 2. Fluxo de Status e Lógica de Recalculo

### 2.1 Ciclo de vida do Pedido

```
         ┌─────────────────────────────────┐
         │  rejeição (Pending → New)       │
         ▼                                 │
        NEW ──────────► PENDING APPROVAL ──┘
                               │
                               │ (aprovação final, sem rollback)
                               ▼
                           APPROVED  ←── estado terminal
```

**Não existe transição de APPROVED para nenhum outro status.** Uma vez aprovado, o pedido é imutável do ponto de vista da meta.

A rejeição é `Pending Approval → New`: o pedido volta ao início e o vendedor pode renegociar.

### 2.2 Recalculo Total — a abordagem correta

Os valores de Negociado, Projetado e Realizado são **sempre um reflexo do estado atual dos pedidos**, não uma acumulação de deltas. O engine recalcula os três campos do zero a cada execução:

```
Projetado__c  = SUM(order_items matched | Order.Status = 'New')
Negociado__c  = SUM(order_items matched | Order.Status = 'Pending Approval')
Realizado__c  = SUM(order_items matched | Order.Status = 'Approved')
```

**Por que isso elimina complexidade:**

| Transição | Efeito no recalculo | Lógica especial? |
|---|---|---|
| `New → Pending Approval` | Projetado diminui, Negociado aumenta | Não — o recalculo captura automaticamente |
| `Pending Approval → Approved` | Negociado diminui, Realizado aumenta | Não — idem |
| `Pending Approval → New` (rejeição) | Negociado diminui, Projetado aumenta | Não — idem |
| Qualquer edição no pedido (itens, valor) | Todos os campos reajustados | Não — idem |

Não existe `IStatusTransitionStrategy`. A lógica de "qual campo atualizar" está implícita no próprio recalculo — basta filtrar por status no SOQL.

### 2.3 Escopo do recalculo

O recalculo não é global. Para cada execução do engine disparada por um conjunto de pedidos, o escopo é:

```
Todos os pedidos do período da meta
  WHERE OwnerId = vendedor do pedido alterado
  AND   produto/família/pagamento match com o Goal Item
```

Isso garante consistência: se outro pedido do mesmo vendedor foi alterado antes e está em `Pending Approval`, ele continuará somando no `Negociado__c` do mesmo Goal Item.

---

## 3. Relação N:N — Pedido ↔ Goal Items

### 3.1 Um pedido pode satisfazer múltiplos Goal Items

Esta é uma decisão de design central: **a correlação entre pedido e meta é N para N**.

```
Order__c (Pedido A)
  ├─ Order_Item__c: Produto X  (família SaaS, pagamento Boleto)
  └─ Order_Item__c: Produto Y  (família Hardware, pagamento Cartão)

Goal__c (Meta do vendedor)
  ├─ Goal_Item__c [RT: Familia]     → família = 'SaaS'       ← Pedido A contribui
  ├─ Goal_Item__c [RT: Familia]     → família = 'Hardware'   ← Pedido A contribui
  ├─ Goal_Item__c [RT: Cond.Pgto]   → condição = 'Boleto'    ← Pedido A contribui (só item X)
  └─ Goal_Item__c [RT: Produto]     → produto = Produto Z    ← Pedido A NÃO contribui
```

O engine avalia **cada Goal Item de forma independente** contra o conjunto de Order Items do pedido. Não há exclusividade — um Order Item pode contribuir para múltiplos Goal Items de critérios distintos.

### 3.2 Implicação para o recalculo

O recalculo de cada Goal Item é independente:

```
Para Goal_Item_A (família SaaS):
  Negociado__c = SUM(
    order_items
    WHERE order.ownerId = vendedor
    AND   order.status  = 'Pending Approval'
    AND   order.period  = meta.period
    AND   product.family = 'SaaS'          ← critério do Goal Item A
  )

Para Goal_Item_B (condição Boleto):
  Negociado__c = SUM(
    order_items
    WHERE order.ownerId       = vendedor
    AND   order.status        = 'Pending Approval'
    AND   order.period        = meta.period
    AND   paymentCondition    = 'Boleto'   ← critério do Goal Item B
  )
```

Mesmos pedidos, lentes diferentes.

---

## 4. Arquitetura do Motor de Atribuição

### 4.1 Visão de componentes

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ORDER TRIGGER LAYER                          │
│                                                                     │
│  OrderTrigger (after update)                                        │
│    └─ OrderTriggerHandler.afterUpdate()                             │
│         └─ Filtra: só registros onde Status mudou                   │
│              └─ publica GoalAttributionEvent__e (Platform Event)    │
└─────────────────────────────────┬───────────────────────────────────┘
                                  │ async — falha aqui não afeta o pedido
┌─────────────────────────────────▼───────────────────────────────────┐
│                    GOAL ATTRIBUTION ENGINE                          │
│                                                                     │
│  GoalAttributionOrchestrator          [Facade]                      │
│    │                                                                │
│    ├─ GoalRepository                  [Repository]  — 1 SOQL       │
│    ├─ GoalItemRepository              [Repository]  — 1 SOQL       │
│    ├─ OrderItemRepository             [Repository]  — 1 SOQL       │
│    │   (todos os pedidos do período, não só o alterado)            │
│    │                                                                │
│    ├─ GoalMatchingEngine              [Strategy + Factory]          │
│    │    ├─ GoalMatchingStrategyFactory   (chave: RecordType)        │
│    │    ├─ ProductMatchingStrategy                                  │
│    │    ├─ FamilyMatchingStrategy                                   │
│    │    ├─ PerformanceMatchingStrategy                              │
│    │    └─ PaymentConditionMatchingStrategy                         │
│    │                                                                │
│    ├─ GoalAttributionCalculator       — agrega por status          │
│    │   (Projetado / Negociado / Realizado em uma passagem)         │
│    │                                                                │
│    └─ UnitOfWork.commitWork()         [UoW]  — 1 DML               │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│                      BATCH LAYER (09h diário)                       │
│                                                                     │
│  GoalAchievementBatch  [Template Method]                            │
│    ├─ start():    query Goal__c ativo no período corrente           │
│    ├─ execute():  GoalSummaryService.evaluate(goals)                │
│    │               → compara Realizado__c vs Target__c             │
│    │               → atualiza Goal__c.Status__c = 'Batida'         │
│    └─ finish():   Platform Event / Email de notificação             │
└─────────────────────────────────────────────────────────────────────┘
```

### 4.2 Por que Strategy continua sendo o padrão central

O algoritmo de matching **varia por Record Type** do Goal Item, mas o fluxo do engine é sempre o mesmo:

```
engine.match(allOrderItemsOfVendor, goalItem) → MatchResult
```

Cada Record Type tem sua própria strategy, selecionada pelo factory via `RecordType.DeveloperName`. O engine não precisa saber qual strategy está rodando — ele só chama `strategy.match(...)` e recebe o resultado.

**O factory usa Custom Metadata** para mapear DeveloperName → nome da classe Apex, tornando a adição de novos tipos de Goal Item um exercício de configuração, não de código.

```
Goal_Matching_Strategy__mdt
  ├─ Goal_Item_RecordType_DeveloperName__c  (ex: 'Goal_Item_Familia')
  └─ Apex_Class_Name__c                     (ex: 'FamilyMatchingStrategy')
```

---

## 5. Diagrama de Classes (Intenção)

```
«interface»
IGoalMatchingStrategy
  + match(
      allOrderItemsOfVendor: List<OrderItem_DTO>,
      goalItem:              GoalItem_DTO
    ): MatchResult
       │
       ├─ ProductMatchingStrategy
       │     Filtra: orderItem.productId = goalItem.productId__c
       │
       ├─ FamilyMatchingStrategy
       │     Filtra: orderItem.productFamily = goalItem.productFamily__c
       │
       ├─ PerformanceMatchingStrategy
       │     Filtra: todos os order items do vendedor no período
       │     (sem filtro de produto — meta de volume total)
       │
       └─ PaymentConditionMatchingStrategy
             Filtra: orderItem.paymentCondition = goalItem.paymentCondition__c


GoalMatchingStrategyFactory
  - cmtMap: Map<String, IGoalMatchingStrategy>   (carregado de CMDT)
  + getStrategy(recordTypeDeveloperName: String): IGoalMatchingStrategy


GoalMatchingEngine
  - factory: GoalMatchingStrategyFactory
  + matchAll(
      allOrderItems: List<OrderItem_DTO>,
      goalItems:     List<GoalItem_DTO>
    ): List<MatchResult>
    ─────────────────────────────────────────
    Para cada goalItem:
      strategy = factory.getStrategy(goalItem.recordTypeDeveloperName)
      result   = strategy.match(allOrderItems, goalItem)
    Retorna: um MatchResult por goalItem (N:N capturado aqui)


GoalAttributionCalculator
  + calculate(matches: List<MatchResult>): List<GoalItem_DTO>
    ─────────────────────────────────────────
    Para cada MatchResult:
      Projetado__c  = SUM(item.amount WHERE item.orderStatus = 'New')
      Negociado__c  = SUM(item.amount WHERE item.orderStatus = 'Pending Approval')
      Realizado__c  = SUM(item.amount WHERE item.orderStatus = 'Approved')
    (uma única iteração sobre matchedItems para os 3 campos)


GoalAttributionOrchestrator   «Facade»
  - goalRepo:      IGoalRepository
  - goalItemRepo:  IGoalItemRepository
  - orderItemRepo: IOrderItemRepository
  - matchEngine:   GoalMatchingEngine
  - calculator:    GoalAttributionCalculator
  - uow:           IUnitOfWork
  + process(ownerIds: Set<Id>, periodIds: Set<Id>): void
```

---

## 6. Diagrama de Sequência — Trigger After Update

```
OrderTrigger    Handler      PlatformEvent   Orchestrator    Repositories    Engine        UoW
    │              │               │               │               │             │            │
    │ after update  │               │               │               │             │            │
    │──────────────►│               │               │               │             │            │
    │              │ filter        │               │               │             │            │
    │              │ status changed│               │               │             │            │
    │              │───────────────►               │               │             │            │
    │              │        publish GoalAttributionEvent__e        │             │            │
    │              │  (ownerIds, periodId)         │               │             │            │
    │◄─────────────│               │               │               │             │            │
    │   commit OK  │               │ trigger async │               │             │            │
    │              │               │───────────────►               │             │            │
    │              │               │               │ findGoals(    │             │            │
    │              │               │               │  ownerIds,    │             │            │
    │              │               │               │  periodId)    │             │            │
    │              │               │               │──────────────►│             │            │
    │              │               │               │◄──────────────│  goals      │            │
    │              │               │               │ findGoalItems │             │            │
    │              │               │               │  (goalIds)    │             │            │
    │              │               │               │──────────────►│             │            │
    │              │               │               │◄──────────────│  goalItems  │            │
    │              │               │               │ findAllOrder  │             │            │
    │              │               │               │  Items(owner  │             │            │
    │              │               │               │  Ids, period) │             │            │
    │              │               │               │──────────────►│             │            │
    │              │               │               │◄──────────────│  orderItems │            │
    │              │               │               │ matchAll(     │             │            │
    │              │               │               │  orderItems,  │             │            │
    │              │               │               │  goalItems)   │             │            │
    │              │               │               │───────────────────────────►│            │
    │              │               │               │  [N goals × Strategy]      │            │
    │              │               │               │◄───────────────────────────│            │
    │              │               │               │  List<MatchResult>         │            │
    │              │               │               │ calculate(matches)         │            │
    │              │               │               │  (Proj/Neg/Real por item)  │            │
    │              │               │               │ register updates           │            │
    │              │               │               │────────────────────────────────────────►│
    │              │               │               │ commitWork()               │            │
    │              │               │               │────────────────────────────────────────►│
    │              │               │               │                            │  DML 1x    │
```

### Contagem de operações (bulkified, N pedidos de M vendedores)

| Operação | Quantidade | Observação |
|---|---|---|
| SOQL Goals | 1 | `WHERE Owner__c IN :ownerIds AND Period__c = :periodId AND Status = 'Ativo'` |
| SOQL Goal Items | 1 | `WHERE Goal__c IN :goalIds` (com RecordType.DeveloperName) |
| SOQL Order Items | 1 | Todos os pedidos do período para esses vendedores (não só o que mudou) |
| DML Update Goal Items | 1 | Via UnitOfWork |
| **Total** | **3 SOQL + 1 DML** | Independente do volume de pedidos ou goal items |

---

## 7. Interfaces — Contratos de Cada Componente

### IGoalMatchingStrategy

```
Entrada:
  - allOrderItemsOfVendor: List<OrderItem_DTO>
      (todos os order items do vendedor no período, já carregados)
  - goalItem: GoalItem_DTO
      (inclui recordTypeDeveloperName e campos de critério do RT específico)

Saída:
  - MatchResult
      - goalItemId:    Id
      - matchedItems:  List<OrderItem_DTO>   (apenas os que passaram no filtro)
        ⚑ cada item carrega orderStatus para o calculator separar Proj/Neg/Real

Invariantes:
  - Nunca retorna null; lista vazia se nada bate
  - Não executa SOQL (dados já fornecidos pelo Orchestrator)
  - Não executa DML
  - Não conhece os campos Negociado/Projetado/Realizado (responsabilidade do Calculator)
```

### GoalAttributionCalculator

```
Entrada:
  - matches: List<MatchResult>

Saída:
  - List<GoalItem_DTO>
      Cada DTO contém os três campos calculados:
        Projetado__c  = SUM(item.amount | item.orderStatus = 'New')
        Negociado__c  = SUM(item.amount | item.orderStatus = 'Pending Approval')
        Realizado__c  = SUM(item.amount | item.orderStatus = 'Approved')

Invariantes:
  - Um único loop sobre matchedItems por MatchResult (O(n), sem aninhamento)
  - Sempre sobrescreve os três campos (nunca atualiza só um)
  - Não executa SOQL nem DML
```

### GoalAttributionOrchestrator

```
Entrada:
  - ownerIds:  Set<Id>   (vendedores dos pedidos que mudaram de status)
  - periodId:  Id        (período da meta — extraído do Goal__c ativo)

Saída: void (side effect: DML em Goal_Item__c)

Invariantes:
  - Idempotente: rodar duas vezes produz o mesmo resultado (recalculo, não delta)
  - Falha no engine não propaga para a transação do pedido (via Platform Event)
  - Máximo 3 SOQL + 1 DML por execução
  - Deve logar erros em objeto de auditoria sem relançar exceção
```

---

## 8. Diagrama de Sequência — Batch 09h

```
Scheduler   GoalAchievementBatch    GoalSummaryService    UoW
    │               │                       │              │
    │ 09h00         │                       │              │
    │───────────────►│                       │              │
    │               │ start()               │              │
    │               │ query Goal__c ativo   │              │
    │               │ do período corrente   │              │
    │               │                       │              │
    │               │ execute(scope)        │              │
    │               │───────────────────────►              │
    │               │                       │ aggregate    │
    │               │                       │ Realizado__c │
    │               │                       │ de todos os  │
    │               │                       │ Goal Items   │
    │               │                       │              │
    │               │                       │ compare vs   │
    │               │                       │ Target__c    │
    │               │                       │              │
    │               │                       │ if >=:       │
    │               │                       │ Status='Batida'
    │               │                       │──────────────►│
    │               │                       │  commitWork() │
    │               │◄───────────────────────              │
    │               │ finish()              │              │
    │               │ Platform Event /      │              │
    │               │ Email Notification    │              │
```

---

## 9. Mapa de Padrões Aplicados

| Componente | Padrão | Justificativa |
|---|---|---|
| `IGoalMatchingStrategy` + implementações | **Strategy** | Algoritmo de filtragem de Order Items varia por Record Type do Goal Item; cada variação é isolada e testável |
| `GoalMatchingStrategyFactory` | **Factory Method** | Seleciona strategy por `RecordType.DeveloperName`; configurável via CMDT sem deploy |
| `GoalMatchingEngine` | **Strategy** (coordinator) | Itera sobre todos os goal items e aplica a strategy correta a cada um, capturando relação N:N |
| `GoalAttributionOrchestrator` | **Facade** | API simples para o trigger handler; isola os 3 SOQLs e o DML |
| `GoalRepository`, `GoalItemRepository`, `OrderItemRepository` | **Repository** | Isola todo SOQL; permite mock nos testes unitários sem dados na org |
| `UnitOfWork` | **Command / UoW** | Centraliza DML; 1 statement independente do número de goal items afetados |
| `GoalAchievementBatch` | **Template Method** | Fluxo fixo (start/execute/finish); `GoalSummaryService` é o passo variável |
| Platform Event `GoalAttributionEvent__e` | **Observer** | Desacopla o trigger do engine; falha no engine não reverte o pedido |
| DTOs (`OrderItem_DTO`, `GoalItem_DTO`, `MatchResult`, etc.) | **Value Object** | Transportam dados entre camadas sem expor SObjects; facilitam mock e assert nos testes |

---

## 10. Decisões Arquiteturais

### 10.1 Record Type como chave do Factory (não picklist)

Usar `RecordType.DeveloperName` como chave do factory alinha o engine com o modelo de dados Salesforce. Vantagens:
- Record Types já estão no SOQL via `RecordType.DeveloperName` sem campo adicional
- Cada RT pode ter page layout próprio com campos específicos (ex: `Product__c` no RT Produto, `Product_Family__c` no RT Família)
- Adicionar novo tipo = criar RT + CMDT entry + nova Strategy class (sem alterar o factory)

### 10.2 Recalculo total vs. acumulação incremental

**Escolhido: recalculo total.** Os valores são sempre um reflexo dos pedidos existentes — não há estado acumulado em `Goal_Item__c` que diverge da realidade dos pedidos. Consequências:

- Idempotência nativa: processar o mesmo evento duas vezes não duplica valores
- Rejeição (`Pending → New`) sem lógica especial de rollback
- Edição de itens do pedido (sem mudar status) correta desde que o engine seja re-disparado
- Custo: 1 SOQL extra para buscar TODOS os pedidos do período (não só o alterado)

### 10.3 Async obrigatório via Platform Event

O pedido não deve falhar porque uma meta não pôde ser atualizada. Meta é efeito colateral, não core da transação de negócio do pedido.

```
Trigger publica: GoalAttributionEvent__e
  ├─ ownerIds  (Set<Id>)
  └─ periodId  (Id do período da meta ativa)

Engine consome o evento e processa de forma independente.
```

### 10.4 Fluxo de status — sem rollback de Approved

`Approved` é estado terminal. As únicas transições suportadas:

```
New              → Pending Approval   (início da negociação)
Pending Approval → Approved           (aprovação final)
Pending Approval → New                (rejeição — volta para renegociar)
```

O recalculo total trata a rejeição automaticamente: ao voltar para `New`, o próximo recalculo tira o valor de `Negociado__c` e o reflete em `Projetado__c`.

---

## 11. Estrutura de Pacotes Sugerida

```
force-app/main/default/classes/
  goalChallenge/
    ├─ engine/
    │    ├─ GoalAttributionOrchestrator.cls    [Facade]
    │    ├─ GoalMatchingEngine.cls             [Strategy coordinator]
    │    └─ GoalAttributionCalculator.cls      [Proj/Neg/Real em uma passagem]
    │
    ├─ strategies/
    │    ├─ IGoalMatchingStrategy.cls
    │    ├─ GoalMatchingStrategyFactory.cls    [Factory + CMDT]
    │    ├─ ProductMatchingStrategy.cls
    │    ├─ FamilyMatchingStrategy.cls
    │    ├─ PerformanceMatchingStrategy.cls
    │    └─ PaymentConditionMatchingStrategy.cls
    │
    ├─ repositories/
    │    ├─ IGoalRepository.cls
    │    ├─ GoalRepository.cls
    │    ├─ IGoalItemRepository.cls
    │    ├─ GoalItemRepository.cls
    │    ├─ IOrderItemRepository.cls
    │    └─ OrderItemRepository.cls
    │
    ├─ batch/
    │    └─ GoalAchievementBatch.cls           [Template Method]
    │
    ├─ services/
    │    └─ GoalSummaryService.cls
    │
    └─ dto/
         ├─ OrderItem_DTO.cls                  (carrega orderStatus para o Calculator)
         ├─ GoalItem_DTO.cls                   (carrega recordTypeDeveloperName)
         ├─ MatchResult.cls
         └─ AttributionFieldConfig.cls         (Proj/Neg/Real calculados)
```

---

## 12. Pontos em Aberto (a confirmar com o negócio)

| # | Questão | Impacto |
|---|---|---|
| 1 | `Projetado` e `Negociado` são dois campos distintos ou apenas um? | Define se Calculator popula 2 ou 3 campos; design atual assume ambos existem |
| 2 | `PerformanceMatchingStrategy`: KPI é receita total, quantidade de pedidos, ou margem? | Define o campo somado no calculator para esse RT |
| 3 | Metas têm período explícito (lookup para objeto Período)? | Define o filtro de SOQL no repository; sem período, recalculo pode ser gigante |
| 4 | Um vendedor pode ter múltiplas metas ativas no mesmo período? | Engine atual suporta; confirmar se há regra de precedência |
| 5 | Order Items têm valor unitário ou total de linha? | Define o campo somado no Calculator (`UnitPrice × Quantity` ou `TotalPrice`) |
| 6 | O batch de 09h recalcula os valores de Goal Item antes de checar o Target, ou confia nos valores já atribuídos pelo engine? | Se confia nos valores, o batch só lê; se recalcula, o batch chama o engine |

---

## 13. Checklist Pré-Desenvolvimento

- [ ] Confirmar DeveloperNames dos Record Types de `Goal_Item__c`
- [ ] Confirmar campos de critério de cada Record Type (ex: qual campo carrega `Product2Id` no RT Produto)
- [ ] Confirmar campos `Projetado__c`, `Negociado__c`, `Realizado__c` em `Goal_Item__c`
- [ ] Confirmar campo de período em `Goal__c` (lookup, date range, ou ano/mês)
- [ ] Decidir: batch recalcula valores ou só lê e compara?
- [ ] Criar CMDT `Goal_Matching_Strategy__mdt` com estrutura mapeada acima
- [ ] Planejar testes unitários por Strategy antes de qualquer implementação
- [ ] Validar volume esperado de pedidos por período por vendedor (impacto no SOQL de Order Items)
