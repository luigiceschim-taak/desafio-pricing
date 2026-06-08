# Prompt — Implementação do Motor de Atribuição de Metas (Salesforce Apex)

> Cole este prompt diretamente no Claude Code para iniciar a implementação.

---

## Contexto do Projeto

Você irá implementar um **motor de atribuição de metas** em Salesforce Apex seguindo um UML previamente planejado. O objetivo é: quando o status de um `Order__c` (Pedido) muda, o sistema deve encontrar metas ativas (`Goal__c`) do vendedor dono do pedido e atualizar os campos de valor nos itens dessas metas (`Goal_Item__c`) com base nos itens do pedido (`OrderItem`) que combinam com os critérios de cada item de meta.

A API version do projeto é **66.0**. Todos os arquivos `.cls` devem ter o `.cls-meta.xml` correspondente com `<apiVersion>66.0</apiVersion>`.

---

## Objetos Salesforce Envolvidos

### Goal__c (Meta)
- `Owner__c` — Lookup para User (o vendedor)
- `Status__c` — Picklist: `Ativo`, `Inativo`, `Batida`
- `Target__c` — Currency (meta total)

### Goal_Item__c (Item de Meta)
- `Goal__c` — Master-Detail para Goal__c
- Record Types (DeveloperName):
  - `Goal_Item_Produto` — campos: `Product__c` (Lookup Product2)
  - `Goal_Item_Familia` — campos: `Product_Family__c` (Text)
  - `Goal_Item_Performance` — sem campo de filtro (agrega tudo do vendedor)
  - `Goal_Item_Condicao_Pagamento` — campos: `Payment_Condition__c` (Text)
- `Target__c` — Currency (meta do item)
- `Projetado__c` — Currency (soma dos OrderItems com status New)
- `Negociado__c` — Currency (soma dos OrderItems com status Pending Approval)
- `Realizado__c` — Currency (soma dos OrderItems com status Approved)

### Order__c (Pedido)
- `OwnerId` — standard field (o vendedor)
- `Status` — standard picklist: `New`, `Pending Approval`, `Approved`, `Cancelled`

### OrderItem (Item do Pedido — standard Salesforce object)
- `Product2Id` — Lookup Product2
- `Product2.Family` — campo relacionado
- `Payment_Condition__c` — Text (campo custom no OrderItem)
- `UnitPrice` — Currency
- `Order.Status` — via relationship
- `Order.OwnerId` — via relationship

---

## Arquitetura — Padrões Aplicados

- **Facade** — `GoalAttributionFacade`: único ponto de entrada, orquestra tudo
- **Strategy** — `IGoalMatchingStrategy`: algoritmo de match varia por Record Type
- **Factory Method** — `GoalMatchingStrategyFactory`: seleciona Strategy via Custom Metadata
- **Repository** — interfaces `IGoalRepository`, `IGoalItemRepository`, `IOrderItemRepository`: isolam SOQL para testabilidade
- **Value Objects** — DTOs imutáveis que trafegam dados entre camadas sem expor SObjects diretamente

---

## Fluxo de Execução

```
OrderTrigger (after update — status changed)
  └─ OrderTriggerHandler.afterUpdate(newMap, oldMap)
        └─ GoalAttributionFacade.process(List<OrderStatusChange>)
              ├─ IGoalRepository.findActiveByOwners(ownerIds)       → 1 SOQL
              ├─ IGoalItemRepository.findByGoals(goalIds)           → 1 SOQL
              ├─ IOrderItemRepository.findByOwners(ownerIds)        → 1 SOQL
              ├─ para cada GoalItem_DTO:
              │     factory.getStrategy(recordTypeDeveloperName)
              │     strategy.match(allOrderItems, goalItem)         → filtra IDs
              │     calcula Projetado / Negociado / Realizado
              └─ update Goal_Item__c                                → 1 DML

GoalAchievementBatch (Scheduled — 09h diário)
  └─ start():   SELECT Goal__c WHERE Status__c = 'Ativo'
  └─ execute(): verifica se Realizado__c >= Target__c → Status__c = 'Batida'
  └─ finish():  (reservado para notificações futuras)
```

**Regra do recálculo total — IMPORTANTE:**
Os três campos (`Projetado__c`, `Negociado__c`, `Realizado__c`) são sempre recalculados do zero, nunca acumulados por delta.

```
Projetado__c = SUM(matched orderItems WHERE Order.Status = 'New')
Negociado__c = SUM(matched orderItems WHERE Order.Status = 'Pending Approval')
Realizado__c = SUM(matched orderItems WHERE Order.Status = 'Approved')
```

---

## Estrutura de Pastas

Crie todos os arquivos dentro de:
```
force-app/main/default/classes/goalChallenge/
  ├─ dto/
  │    ├─ OrderStatusChange.cls
  │    ├─ OrderItem_DTO.cls
  │    └─ GoalItem_DTO.cls
  ├─ interfaces/
  │    ├─ IGoalRepository.cls
  │    ├─ IGoalItemRepository.cls
  │    └─ IOrderItemRepository.cls
  ├─ strategies/
  │    ├─ IGoalMatchingStrategy.cls
  │    ├─ GoalMatchingStrategyFactory.cls
  │    ├─ ProductMatchingStrategy.cls
  │    ├─ FamilyMatchingStrategy.cls
  │    ├─ PerformanceMatchingStrategy.cls
  │    └─ PaymentConditionMatchingStrategy.cls
  ├─ repositories/
  │    ├─ GoalRepository.cls
  │    ├─ GoalItemRepository.cls
  │    └─ OrderItemRepository.cls
  ├─ facade/
  │    └─ GoalAttributionFacade.cls
  ├─ trigger/
  │    └─ OrderTriggerHandler.cls (se não existir)
  └─ batch/
       └─ GoalAchievementBatch.cls

force-app/main/default/triggers/
  └─ OrderTrigger.trigger (se não existir)

force-app/main/default/customMetadata/
  └─ Goal_Matching_Strategy.Goal_Item_Produto.md-meta.xml
  └─ Goal_Matching_Strategy.Goal_Item_Familia.md-meta.xml
  └─ Goal_Matching_Strategy.Goal_Item_Performance.md-meta.xml
  └─ Goal_Matching_Strategy.Goal_Item_Condicao_Pagamento.md-meta.xml
```

---

## Especificação de Cada Classe

### DTOs (sem lógica, só campos públicos)

**OrderStatusChange**
```
public String orderId
public String ownerId
public String fromStatus
public String toStatus
```

**OrderItem_DTO**
```
public Id id
public Id ownerId
public String orderStatus
public Id productId
public String productFamily
public String paymentCondition
public Decimal amount
```

**GoalItem_DTO**
```
public Id id
public Id goalId
public String recordTypeDeveloperName
public Id productId
public String productFamily
public String paymentCondition
public Decimal target
public Decimal projetado
public Decimal negociado
public Decimal realizado
```

---

### Interfaces dos Repositories

```apex
public interface IGoalRepository {
    List<GoalItem_DTO> findActiveByOwners(Set<Id> ownerIds);
}

public interface IGoalItemRepository {
    List<GoalItem_DTO> findByGoals(Set<Id> goalIds);
}

public interface IOrderItemRepository {
    List<OrderItem_DTO> findByOwners(Set<Id> ownerIds);
}
```

---

### IGoalMatchingStrategy

```apex
public interface IGoalMatchingStrategy {
    List<OrderItem_DTO> match(List<OrderItem_DTO> orderItems, GoalItem_DTO goalItem);
}
```

Cada implementação:
- `ProductMatchingStrategy`: retorna `orderItems` onde `orderItem.productId == goalItem.productId`
- `FamilyMatchingStrategy`: retorna onde `orderItem.productFamily == goalItem.productFamily`
- `PerformanceMatchingStrategy`: retorna **todos** os orderItems (sem filtro)
- `PaymentConditionMatchingStrategy`: retorna onde `orderItem.paymentCondition == goalItem.paymentCondition`

---

### GoalMatchingStrategyFactory

Lê `Goal_Matching_Strategy__mdt` em `loadFromCMDT()` no construtor e popula um `Map<String, IGoalMatchingStrategy>`.

```apex
private Map<String, IGoalMatchingStrategy> cmtMap = new Map<String, IGoalMatchingStrategy>();

public IGoalMatchingStrategy getStrategy(String recordTypeDeveloperName) {
    if (!cmtMap.containsKey(recordTypeDeveloperName)) {
        throw new GoalMatchingException('Estratégia não encontrada para: ' + recordTypeDeveloperName);
    }
    return cmtMap.get(recordTypeDeveloperName);
}

private void loadFromCMDT() {
    for (Goal_Matching_Strategy__mdt cfg :
            [SELECT RecordType_DeveloperName__c, Apex_Class_Name__c
             FROM Goal_Matching_Strategy__mdt
             WHERE Active__c = true]) {
        Type t = Type.forName(cfg.Apex_Class_Name__c);
        cmtMap.put(cfg.RecordType_DeveloperName__c, (IGoalMatchingStrategy) t.newInstance());
    }
}
```

---

### Repositories (implementações)

**GoalRepository** — query:
```sql
SELECT Id, Owner__c
FROM Goal__c
WHERE Owner__c IN :ownerIds
AND Status__c = 'Ativo'
```

**GoalItemRepository** — query:
```sql
SELECT Id, Goal__c, RecordType.DeveloperName,
       Product__c, Product_Family__c, Payment_Condition__c, Target__c,
       Projetado__c, Negociado__c, Realizado__c
FROM Goal_Item__c
WHERE Goal__c IN :goalIds
```

**OrderItemRepository** — query:
```sql
SELECT Id, Product2Id, Product2.Family,
       Payment_Condition__c, UnitPrice,
       Order.Status, Order.OwnerId
FROM OrderItem
WHERE Order.OwnerId IN :ownerIds
AND Order.Status != 'Cancelled'
```

---

### GoalAttributionFacade

Orquestra o fluxo completo:

```
1. Se changes for vazio → return
2. extractOwnerIds(changes) → Set<Id>
3. Se ownerIds vazio → return
4. goalRepo.findActiveByOwners(ownerIds) → List<Goal_DTO>
5. Se goals vazio → return
6. goalItemRepo.findByGoals(goalIds) → List<GoalItem_DTO>
7. orderItemRepo.findByOwners(ownerIds) → List<OrderItem_DTO>
8. List<Goal_Item__c> toUpdate = new List<Goal_Item__c>()
9. Para cada GoalItem_DTO:
     strategy = factory.getStrategy(goalItem.recordTypeDeveloperName)
     matched  = strategy.match(allOrderItems, goalItem)
     calculado = calculate(matched, goalItem)
     toUpdate.add( new Goal_Item__c com os 3 campos )
10. if (!toUpdate.isEmpty()) update toUpdate
```

O método `calculate(matched, goalItem)` percorre `matched` uma única vez e acumula os três valores por `orderStatus`.

---

### OrderTriggerHandler

```apex
public class OrderTriggerHandler {
    public void afterUpdate(Map<Id, Order> newMap, Map<Id, Order> oldMap) {
        List<OrderStatusChange> changes = filterStatusChanged(newMap, oldMap);
        if (!changes.isEmpty()) {
            new GoalAttributionFacade().process(changes);
        }
    }

    private List<OrderStatusChange> filterStatusChanged(
            Map<Id, Order> newMap, Map<Id, Order> oldMap) {
        List<OrderStatusChange> result = new List<OrderStatusChange>();
        for (Id orderId : newMap.keySet()) {
            Order newOrd = newMap.get(orderId);
            Order oldOrd = oldMap.get(orderId);
            if (newOrd.Status != oldOrd.Status) {
                OrderStatusChange ch = new OrderStatusChange();
                ch.orderId    = orderId;
                ch.ownerId    = newOrd.OwnerId;
                ch.fromStatus = oldOrd.Status;
                ch.toStatus   = newOrd.Status;
                result.add(ch);
            }
        }
        return result;
    }
}
```

---

### OrderTrigger

```apex
trigger OrderTrigger on Order (after update) {
    new OrderTriggerHandler().afterUpdate(Trigger.newMap, Trigger.oldMap);
}
```

---

### GoalAchievementBatch

```apex
public class GoalAchievementBatch implements Database.Batchable<SObject> {

    public Database.QueryLocator start(Database.BatchableContext ctx) {
        return Database.getQueryLocator(
            'SELECT Id, Target__c, ' +
            '(SELECT Id, Realizado__c FROM Goal_Items__r) ' +
            'FROM Goal__c WHERE Status__c = \'Ativo\''
        );
    }

    public void execute(Database.BatchableContext ctx, List<Goal__c> scope) {
        List<Goal__c> toUpdate = new List<Goal__c>();
        for (Goal__c g : scope) {
            if (isAchieved(g)) {
                toUpdate.add(new Goal__c(Id = g.Id, Status__c = 'Batida'));
            }
        }
        if (!toUpdate.isEmpty()) update toUpdate;
    }

    public void finish(Database.BatchableContext ctx) {}

    private Boolean isAchieved(Goal__c g) {
        Decimal totalRealizado = 0;
        for (Goal_Item__c item : g.Goal_Items__r) {
            totalRealizado += (item.Realizado__c != null ? item.Realizado__c : 0);
        }
        return g.Target__c != null && totalRealizado >= g.Target__c;
    }
}
```

---

## Custom Metadata — Goal_Matching_Strategy__mdt

Criar o objeto Custom Metadata `Goal_Matching_Strategy__mdt` com os campos:
- `RecordType_DeveloperName__c` (Text 80, único)
- `Apex_Class_Name__c` (Text 255)
- `Active__c` (Checkbox, default true)

Criar os 4 registros:

| Label | RecordType_DeveloperName__c | Apex_Class_Name__c | Active__c |
|---|---|---|---|
| Produto | Goal_Item_Produto | ProductMatchingStrategy | true |
| Família | Goal_Item_Familia | FamilyMatchingStrategy | true |
| Performance | Goal_Item_Performance | PerformanceMatchingStrategy | true |
| Condição Pagamento | Goal_Item_Condicao_Pagamento | PaymentConditionMatchingStrategy | true |

---

## Classes de Teste — Requisitos

Criar um teste por classe de produção seguindo o padrão `NomeClasseTest.cls`.

**Regras obrigatórias para todos os testes:**
- Usar `@isTest` e `@TestSetup` para dados compartilhados
- Nunca usar `seeAllData = true`
- Cada teste deve ter pelo menos 1 `System.assert`
- Cobrir o caminho feliz e o caminho sem resultado (lista vazia)

**Testes prioritários:**
1. `ProductMatchingStrategyTest` — deve validar que só retorna order items com o mesmo productId
2. `FamilyMatchingStrategyTest` — deve validar match por família
3. `PaymentConditionMatchingStrategyTest` — deve validar match por condição
4. `PerformanceMatchingStrategyTest` — deve retornar todos os itens
5. `GoalAttributionFacadeTest` — deve validar que após processar, Negociado/Projetado/Realizado são atualizados corretamente nos Goal Items
6. `GoalAchievementBatchTest` — deve usar `Test.startTest()/stopTest()` e validar que meta com Realizado >= Target recebe Status = 'Batida'

---

## Regras de Qualidade (obrigatórias)

- **Zero SOQL dentro de loops** — todas as queries ficam nos Repositories, fora de qualquer iteração
- **Zero DML dentro de loops** — acumular em lista e executar 1 DML no final
- **Bulkification** — tudo deve funcionar com 200 registros simultâneos
- **Null-safety** — checar nulos antes de somar campos Currency (`!= null ? value : 0`)
- **Fail-safe no factory** — se RecordType não tiver Strategy mapeada, lançar exceção descritiva (não deixar NPE silencioso)
- **Um trigger por objeto** — `OrderTrigger` com uma linha por contexto, delegando para o handler

---

## Ordem de Criação dos Arquivos

```
1.  OrderStatusChange.cls
2.  OrderItem_DTO.cls
3.  GoalItem_DTO.cls
4.  IGoalRepository.cls
5.  IGoalItemRepository.cls
6.  IOrderItemRepository.cls
7.  IGoalMatchingStrategy.cls
8.  ProductMatchingStrategy.cls
9.  FamilyMatchingStrategy.cls
10. PerformanceMatchingStrategy.cls
11. PaymentConditionMatchingStrategy.cls
12. GoalMatchingStrategyFactory.cls
13. GoalRepository.cls
14. GoalItemRepository.cls
15. OrderItemRepository.cls
16. GoalAttributionFacade.cls
17. OrderTriggerHandler.cls
18. OrderTrigger.trigger
19. GoalAchievementBatch.cls
20. Custom Metadata: Goal_Matching_Strategy__mdt + 4 registros
21. Classes de teste na mesma ordem das classes de produção
```

Implemente na ordem acima. Confirme cada etapa antes de avançar para a próxima.
