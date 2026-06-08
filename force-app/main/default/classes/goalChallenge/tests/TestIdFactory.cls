@isTest
public class TestIdFactory {

    private static Integer counter = 1;

    // Gera um Id válido (sem DML) para o SObjectType informado.
    public static Id generate(Schema.SObjectType sobjectType) {
        String prefix = sobjectType.getDescribe().getKeyPrefix();
        String body = String.valueOf(counter++);
        return Id.valueOf(prefix + '000000000000'.substring(0, 12 - body.length()) + body);
    }

    public static Id product() {
        return generate(Product2.SObjectType);
    }

    public static Id goalItem() {
        return generate(GoalItem__c.SObjectType);
    }
}
