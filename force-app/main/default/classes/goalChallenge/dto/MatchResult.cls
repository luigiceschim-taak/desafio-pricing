public class MatchResult {
    public Id goalItemId;
    public List<OrderItem_DTO> matchedItems;

    public MatchResult(Id goalItemId) {
        this.goalItemId = goalItemId;
        this.matchedItems = new List<OrderItem_DTO>();
    }
}
