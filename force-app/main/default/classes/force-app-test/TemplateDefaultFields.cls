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

    public class GrupoContaDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Grupo' + countSObjectCreated
            };
        }
    }

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Demo Account ' + countSObjectCreated,
                'CNPJ__c' => '12345678000195'
            };
        }
    }

    public class PaisDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Pais' + countSObjectCreated,
                'Sigla__c' => 'P' + countSObjectCreated
            };
        }
    }

    public class EstadoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Estado' + countSObjectCreated,
                'Sigla__c' => 'E' + countSObjectCreated
            };
        }
    }
} 