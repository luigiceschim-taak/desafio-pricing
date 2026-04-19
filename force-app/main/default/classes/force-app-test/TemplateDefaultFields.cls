public with sharing class TemplateDefaultFields {
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults(Decimal countSObjectCreated);
    }

    // Minimal defaults for this repository demo tests.

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
                //LOOKUPS: CIDADE, ACCOUNT
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
    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Produto ' + countSObjectCreated,
                'Custo_Producao__c' => 10000 + countSObjectCreated
                
            };
        }
    }
    public class ImpostoDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Imposto ' + countSObjectCreated,
                'Imposto_Custo__c' => 1 + countSObjectCreated,
                'Status__c' => 'Aprovado'
            };
        }
    }

    public class FreteDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Frete ' + countSObjectCreated,
                'Valor__c' => 500 + countSObjectCreated,
                'Status__c' => 'Aprovado'
            };
        }
    }

    public class MargemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Margem ' + countSObjectCreated,
                'Valor__c' => 500 + countSObjectCreated,
                'Status__c' => 'Aprovado'
            };
        }
    }

    public class OrderDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Name' => 'Order ' + countSObjectCreated,
                'Status' => 'Rascunho',
                'Data_Entrega__c' => Date.today().addDays(10),
                'Tipo_Frete__c' => 'CIF',
                'EffectiveDate' => Date.today()
            };
        }
    }

    public class OrderItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults(Decimal countSObjectCreated) {
            return new Map<String, Object>{
                'Quantity' => 1 + countSObjectCreated,
                'UnitPrice' => 7000000 + countSObjectCreated
            };
        }
    }

    
} 