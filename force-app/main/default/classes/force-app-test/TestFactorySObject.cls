public class TestFactorySObject {
    private static TestFactorySObject testFactorySObject;
    private static Decimal countSObjectCreated = 0;

    public static TestFactorySObject getInstance() {
        if (testFactorySObject == null) {
            testFactorySObject = new TestFactorySObject();
        }
        return testFactorySObject;
    }

    @TestVisible
    private static void validateSObject(SObject sObj) {
        if (sObj == null) {
            throw new TestFactoryException('SObject cannot be null');
        }
    }

    private static void addFieldDefaults(SObject sObj, Map<String, Object> defaultFields) {
        for (String fieldApiName : defaultFields.keySet()) {
            if (sObj.get(fieldApiName) == null) {
                sObj.put(fieldApiName, defaultFields.get(fieldApiName));
            }
        }
    }

    public SObject createSObject(SObject sObj) {
        validateSObject(sObj);

        String objectName = String.valueOf(sObj.getSObjectType());
        if (objectName == 'Contract') {
            objectName = 'ContractStandard';
        }

        String defaultClassName =
            'TemplateDefaultFields.' + objectName.replaceAll('__c|__mdt|__|_', '') + 'Defaults';

        return dispatchSObjectCreation(sObj, defaultClassName);
    }

    @TestVisible
    private SObject dispatchSObjectCreation(SObject sObj, String defaultClassName) {
        Type t = Type.forName(defaultClassName);
        if (t == null) {
            throw new TestFactoryException(
                'Invalid defaults class. Missing class: ' + defaultClassName
            );
        }

        TemplateDefaultFields.FieldDefaults defaults =
            (TemplateDefaultFields.FieldDefaults) t.newInstance();
        addFieldDefaults(sObj, defaults.getFieldDefaults(countSObjectCreated));
        countSObjectCreated++;

        return sObj;
    }

    public class TestFactoryException extends Exception {
    }
}