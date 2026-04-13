/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class FreteTest {

    @testSetup
    static void setupTestData() {
        Centro_de_Distribuicao__c centro = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert centro;

        Hierarquia_Produto__c hierarquia = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquia;

        Product2 product = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        product.Hierarquia_Produto__c = hierarquia.Id;
        insert product;
        
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;
        
        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c()); 
        estado.Pais__c = pais.Id;
        insert estado;
        

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        insert cidade;
    }




    @isTest
    static void shouldValidateXorPaisEstadoCidade() {
        // Arrange
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];
        Centro_de_Distribuicao__c centro = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];

        // 1. Apenas Pais
        Frete__c fretePais = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Pais__c = pais.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        insert fretePais;
        System.assertNotEquals(null, fretePais.Id, 'Frete com apenas Pais deve ser inserido');

        // 2. Apenas Estado
        Frete__c freteEstado = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Estado__c = estado.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        insert freteEstado;
        System.assertNotEquals(null, freteEstado.Id, 'Frete com apenas Estado deve ser inserido');

        // 3. Apenas Cidade
        Frete__c freteCidade = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Cidade__c = cidade.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        insert freteCidade;
        System.assertNotEquals(null, freteCidade.Id, 'Frete com apenas Cidade deve ser inserido');

        // 4. Pais e Estado (deve falhar)
        Frete__c fretePaisEstado = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Pais__c = pais.Id, Estado__c = estado.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        try {
            insert fretePaisEstado;
            System.assert(false, 'Não deveria permitir Pais e Estado juntos');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem de erro deve mencionar XOR');
        }

        // 5. Estado e Cidade (deve falhar)
        Frete__c freteEstadoCidade = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Estado__c = estado.Id, Cidade__c = cidade.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        try {
            insert freteEstadoCidade;
            System.assert(false, 'Não deveria permitir Estado e Cidade juntos');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem de erro deve mencionar XOR');
        }

        // 6. Pais e Cidade (deve falhar)
        Frete__c fretePaisCidade = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Pais__c = pais.Id, Cidade__c = cidade.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        try {
            insert fretePaisCidade;
            System.assert(false, 'Não deveria permitir Pais e Cidade juntos');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem de erro deve mencionar XOR');
        }

        // 7. Todos preenchidos (deve falhar)
        Frete__c freteTodos = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c(Pais__c = pais.Id, Estado__c = estado.Id, Cidade__c = cidade.Id, Centro_Distribuicao__c = centro.Id, Produto__c = product.Id));
        try {
            insert freteTodos;
            System.assert(false, 'Não deveria permitir todos juntos');
        } catch (DmlException e) {
            System.assert(e.getMessage() .contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Mensagem de erro deve mencionar XOR');
        }
    }

}