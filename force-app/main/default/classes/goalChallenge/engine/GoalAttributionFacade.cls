public with sharing class GoalAttributionFacade {

    private final IGoalRepository goalRepo;
    private final IGoalItemRepository goalItemRepo;
    private final IOrderItemRepository orderItemRepo;
    private final GoalMatchingEngine matchingEngine;
    private final GoalAttributionCalculator calculator;

    public GoalAttributionFacade() {
        this(
            new GoalRepository(),
            new GoalItemRepository(),
            new OrderItemRepository(),
            new GoalMatchingEngine(new GoalMatchingStrategyFactory()),
            new GoalAttributionCalculator()
        );
    }

    @TestVisible
    private GoalAttributionFacade(
            IGoalRepository goalRepo,
            IGoalItemRepository goalItemRepo,
            IOrderItemRepository orderItemRepo,
            GoalMatchingEngine matchingEngine,
            GoalAttributionCalculator calculator) {
        this.goalRepo = goalRepo;
        this.goalItemRepo = goalItemRepo;
        this.orderItemRepo = orderItemRepo;
        this.matchingEngine = matchingEngine;
        this.calculator = calculator;
    }

    // Ponto de entrada do trigger: filtra pedidos cujo Status mudou e delega ao process.
    public static void run(List<Order> newOrders, Map<Id, Order> oldOrders) {
        List<OrderStatusChange> changes = filterStatusChanged(newOrders, oldOrders);
        if (!changes.isEmpty()) {
            new GoalAttributionFacade().process(changes);
        }
    }

    public void process(List<OrderStatusChange> changes) {
        if (changes == null || changes.isEmpty()) return;

        Set<Id> ownerIds = extractOwnerIds(changes);
        if (ownerIds.isEmpty()) return;

        List<Goal__c> goals = goalRepo.findActiveByOwners(ownerIds);
        if (goals.isEmpty()) return;

        Set<Id> goalIds = new Map<Id, Goal__c>(goals).keySet();

        List<GoalItem_DTO> goalItems = goalItemRepo.findByGoals(goalIds);
        if (goalItems.isEmpty()) return;

        List<OrderItem_DTO> orderItems = orderItemRepo.findByOwners(ownerIds);

        List<MatchResult> matches = matchingEngine.matchAll(orderItems, goalItems);
        Map<Id, GoalItem_DTO> calculated = calculator.calculate(matches);

        List<GoalItem__c> toUpdate = new List<GoalItem__c>();
        for (GoalItem_DTO dto : calculated.values()) {
            toUpdate.add(new GoalItem__c(
                Id = dto.id,
                Projected_Amount__c = dto.projected,
                Negotiated_Value__c = dto.negotiated,
                Realized_Value__c = dto.realized
            ));
        }

        if (!toUpdate.isEmpty()) {
            update toUpdate;
        }
    }

    private static List<OrderStatusChange> filterStatusChanged(
            List<Order> newOrders, Map<Id, Order> oldOrders) {
        List<OrderStatusChange> changes = new List<OrderStatusChange>();
        for (Order newOrder : newOrders) {
            Order oldOrder = oldOrders.get(newOrder.Id);
            if (oldOrder != null && newOrder.Status != oldOrder.Status) {
                changes.add(new OrderStatusChange(
                    newOrder.Id, newOrder.OwnerId, oldOrder.Status, newOrder.Status
                ));
            }
        }
        return changes;
    }

    private Set<Id> extractOwnerIds(List<OrderStatusChange> changes) {
        Set<Id> ownerIds = new Set<Id>();
        for (OrderStatusChange change : changes) {
            if (change.ownerId != null) ownerIds.add(change.ownerId);
        }
        return ownerIds;
    }
}
