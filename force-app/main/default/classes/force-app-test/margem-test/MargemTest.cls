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
private class MargemTest {

    @testSetup
    static void setupTestData() {

         Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

        Centro_de_Distribuicao__c centro = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert centro;

        Grupo_Conta__c grupoConta = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupoConta;
        Account account = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        account.Grupo_Clientes__c = grupoConta.Id;
        insert account;

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
    static void shouldValidateXorPaisEstadoCidadeContaGrupoContaProdutoHierarquiaDeProduto() {
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1][0];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1][0];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1][0];
        Account conta = [SELECT Id FROM Account LIMIT 1][0];
        Grupo_Conta__c grupoConta = [SELECT Id FROM Grupo_Conta__c LIMIT 1][0];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1][0];
        Hierarquia_Produto__c hierarquia = [SELECT Id FROM Hierarquia_Produto__c LIMIT 1][0];
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1][0];

        Margem__c margemValida = (Margem__c)TestFactorySObject.getInstance().createSObject(new Margem__c(
            Cidade__c = cidade.Id,
            Conta__c = conta.Id,
            Produto__c = produto.Id,
            Centro_Distribuicao__c = cd.Id
        ));
        insert margemValida;
        System.assertNotEquals(null, margemValida.Id);

        Margem__c margemInvalida1 = (Margem__c)TestFactorySObject.getInstance().createSObject(new Margem__c(
            Cidade__c = cidade.Id,
            Estado__c = estado.Id,
            Conta__c = conta.Id,
            Produto__c = produto.Id,
            Centro_Distribuicao__c = cd.Id
        ));
        try {
            insert margemInvalida1;
            System.assert(false);
        } catch (DmlException e1) {
            System.assert(e1.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Margem__c margemInvalida2 = (Margem__c)TestFactorySObject.getInstance().createSObject(new Margem__c(
            Cidade__c = cidade.Id,
            Conta__c = conta.Id,
            Grupo_Conta__c = grupoConta.Id,
            Produto__c = produto.Id,
            Centro_Distribuicao__c = cd.Id
        ));
        try {
            insert margemInvalida2;
            System.assert(false);
        } catch (DmlException e2) {
            System.assert(e2.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Margem__c margemInvalida3 = (Margem__c)TestFactorySObject.getInstance().createSObject(new Margem__c(
            Cidade__c = cidade.Id,
            Conta__c = conta.Id,
            Produto__c = produto.Id,
            Hierarquia_Produto__c = hierarquia.Id,
            Centro_Distribuicao__c = cd.Id
        ));
        try {
            insert margemInvalida3;
            System.assert(false);
        } catch (DmlException e3) {
            System.assert(e3.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
        }

        Margem__c margemSemCD = (Margem__c)TestFactorySObject.getInstance().createSObject(new Margem__c(
            Cidade__c = cidade.Id,
            Conta__c = conta.Id,
            Produto__c = produto.Id
        ));
        try {
            insert margemSemCD;
            System.assert(false);
        } catch (DmlException e4) {
            System.assert(e4.getMessage().contains('REQUIRED_FIELD_MISSING'));
        }
    }
}