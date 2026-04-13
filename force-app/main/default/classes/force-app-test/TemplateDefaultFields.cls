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
    public class CidadeDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Cidade' + countSObjectCreated,
                'Codigo_IBGE__c' => '000000' + countSObjectCreated
            };
        }
    }

    public class CentroDeDistribuicaoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Centro de Distribuição ' + countSObjectCreated
            };
        }
    }
    public class CondicaoPagamentoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Condição de Pagamento ' + countSObjectCreated
            };
        }
    }
    
    public class EnderecoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Endereço ' + countSObjectCreated,
                'Bairro__c' => 'Bairro ' + countSObjectCreated,
                'Logradouro__c' => 'Logradouro ' + countSObjectCreated,
                'CEP__c' => '00000-00' + countSObjectCreated

            };
        }
    }
    public class HierarquiaProdutoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Hierarquia de Produto ' + countSObjectCreated
            };
        }
    }
} 