public with sharing class TemplateDefaultFields {
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
    }

    // Minimal defaults for this repository demo tests.
    public class LeadDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'FirstName' => 'Intern',
                'LastName' => 'Demo ' + countSObjectCreated,
                'Company' => 'Taak Routter'
            };
        }
    }
}