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
private class ImpostoServiceTest {

    @testSetup
    static void setupTestData() {
        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);

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

        

        Imposto__c imposto = (Imposto__c) TestFactorySObject.getInstance().createSObject(new Imposto__c());
        imposto.Centro_Distribuicao__c = centro.Id;
        imposto.Product__c = product.Id;
        imposto.Estado__c = estado.Id;
        insert imposto;

        Centro_de_Distribuicao__c centro2 = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert centro2;

        Pais__c pais2 = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais2;

        Estado__c estado2= (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado2.Pais__c = pais2.Id;
        insert estado2;

        Imposto__c imposto2 = (Imposto__c) TestFactorySObject.getInstance().createSObject(new Imposto__c());
        imposto2.Centro_Distribuicao__c = centro2.Id;
        imposto2.Product__c = product.Id;
        imposto2.Estado__c = estado2.Id;
        imposto2.Name = 'Imposto2';
        insert imposto2;
    }

    @isTest
    static void shouldFailWhenDataAlreadyExistsInTheSameLote() {

            Centro_de_Distribuicao__c centro = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
            Product2 product = [SELECT Id FROM Product2 LIMIT 1];
            Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];
    
            
            Imposto__c impostoDuplicado = new Imposto__c(
                Name = 'Imposto Duplicado',
                Centro_Distribuicao__c = centro.Id,
                Product__c = product.Id,
                Estado__c = estado.Id,
                Imposto_Custo__c = 10
            );
            Imposto__c impostoDuplicado2 = new Imposto__c(
                Name = 'Imposto Duplicado',
                Centro_Distribuicao__c = centro.Id,
                Product__c = product.Id,
                Estado__c = estado.Id,
                Imposto_Custo__c = 10
            );

            try{
                insert new List<Imposto__c>{impostoDuplicado, impostoDuplicado2};
                System.assert(false, 'Expected an exception due to duplicate records, but none was thrown.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'), 'Expected error message about duplicate records, but got: ' + e.getMessage());
            }    
    }

    @isTest
    static void shouldFailWhenImpostoCustoIsMinorOrEqualZeroBeforeUpdate(){
            Imposto__c imposto = [SELECT Id, Name, Centro_Distribuicao__c, Product__c, Estado__c,Imposto_Custo__c  FROM Imposto__c LIMIT 1];
            imposto.Imposto_Custo__c = 0;

            List<Imposto__c> impostosToUpdate = new List<Imposto__c>();
            impostosToUpdate.add(imposto);
            
            try{
                
                update impostosToUpdate;
                System.assert(false, 'Expected an exception due to Imposto_Custo__c being zero, but none was thrown.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains('O valor do Imposto de Custo deve ser maior que zero.'), 'Expected error message about Imposto_Custo__c being greater than zero, but got: ' + e.getMessage());
            }
    }

    @isTest
    static void shouldFailWhenDataAlreadyExistsInTheSameLoteAfterUpdate() {
        Imposto__c imposto = [SELECT Id, Name, Centro_Distribuicao__c, Product__c, Estado__c, Imposto_Custo__c FROM Imposto__c LIMIT 1];
        Imposto__c imposto2 = [SELECT Id, Name, Centro_Distribuicao__c, Product__c, Estado__c, Imposto_Custo__c FROM Imposto__c WHERE Name = 'Imposto2' LIMIT 1];

        try {
            imposto.Name = 'Imposto Duplicado';
            imposto.Centro_Distribuicao__c = imposto2.Centro_Distribuicao__c;
            imposto.Estado__c = imposto2.Estado__c;
            imposto.Product__c = imposto2.Product__c; // Garante que todos os campos relevantes estão iguais
            update imposto;
            System.assert(false, 'Expected an exception due to duplicate records, but none was thrown.');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'),
                'Expected error message about duplicate records, but got: ' + e.getMessage()
            );
        }
    }    
} 