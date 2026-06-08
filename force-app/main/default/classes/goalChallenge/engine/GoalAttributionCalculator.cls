public with sharing class GoalAttributionCalculator {

    // Mapeamento dos status de Order para os buckets da meta:
    //   Projected  -> New + PendingApproval                      (pipeline em aberto)
    //   Negotiated -> PendingApproval                            (subconjunto em negociação)
    //   Realized   -> Approved + Integrated + IntegrationError   (permanente, pós-aprovação)
    // Approved/Integrated/IntegrationError formam um conjunto terminal fechado em
    // OrderService.STATUS_TRANSITIONS — um pedido aprovado nunca volta para New/PendingApproval,
    // então o recálculo do zero soma sempre o mesmo total conforme ele avança na integração
    // (nunca regride / zera o realizado).
    // PendingApproval conta em Projected E Negotiated (sobreposição intencional),
    // por isso os testes são independentes (if, não else if).
    private static final Set<String> PROJECTED_STATUSES  = new Set<String>{ 'New', 'PendingApproval' };
    private static final Set<String> NEGOTIATED_STATUSES = new Set<String>{ 'PendingApproval' };
    private static final Set<String> REALIZED_STATUSES   = new Set<String>{ 'Approved', 'Integrated', 'IntegrationError' };

    // Recalculo total: os três campos são sempre derivados do zero, nunca acumulados por delta.
    public Map<Id, GoalItem_DTO> calculate(List<MatchResult> matches) {
        Map<Id, GoalItem_DTO> byGoalItemId = new Map<Id, GoalItem_DTO>();

        for (MatchResult match : matches) {
            GoalItem_DTO dto = new GoalItem_DTO();
            dto.id = match.goalItemId;
            dto.projected = 0;
            dto.negotiated = 0;
            dto.realized = 0;

            for (OrderItem_DTO item : match.matchedItems) {
                Decimal amount = item.amount != null ? item.amount : 0;
                if (PROJECTED_STATUSES.contains(item.orderStatus)) {
                    dto.projected += amount;
                }
                if (NEGOTIATED_STATUSES.contains(item.orderStatus)) {
                    dto.negotiated += amount;
                }
                if (REALIZED_STATUSES.contains(item.orderStatus)) {
                    dto.realized += amount;
                }
            }

            byGoalItemId.put(dto.id, dto);
        }
        return byGoalItemId;
    }
}
