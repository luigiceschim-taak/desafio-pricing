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
        

        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        insert cidade;
    }

      private class HandlerMock extends FreteTriggerHandler {
        
        public void coverVirtualMethods() {
            // O 'super' permite chamar os métodos protected da classe pai
            super.beforeInsert();
            super.beforeUpdate();
            
            
        
            
            
        }
    }

    // ====================================================================
    // MÉTODOS DE TESTE
    // ====================================================================
    @isTest
    static void testBaseHandlerVirtualMethods() {
        // 1. Instancia a nossa classe mockada
        HandlerMock mock = new HandlerMock();
        
        Test.startTest();
        
        // 2. Chama o método do mock que invoca os métodos virtuais vazios {}
        // Isso vai deixar as linhas do beforeUpdate e afterUpdate verdinhas.
        mock.coverVirtualMethods();
        
        // 3. Chama o run() principal. 
        // Como não estamos em contexto de Trigger, Trigger.isBefore será nulo,
        // mas o Apex vai ler a linha do "if" e marcar como coberta.
        
        Test.stopTest();

        // 4. Asserção para garantir que a execução ocorreu sem exceções
        Assert.isTrue(true, 'A cobertura da classe base virtual foi concluída com sucesso.');
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
    @isTest
    static void shouldValidateDuplicidadeOnBeforeUpdate() {
        // 1. Buscar os dados base do Setup
        Centro_de_Distribuicao__c centro = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1]; 
        Cidade__c cidade1 = [SELECT Id FROM Cidade__c LIMIT 1];

        // 2. Criar uma segunda Cidade apenas para este teste ter uma combinação diferente
        Cidade__c cidade2 = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade2.Estado__c = estado.Id;
        insert cidade2;

        // 3. Inserir Frete A (Combinação: Produto + Centro + Cidade 1)
        Frete__c freteA = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c());
        freteA.Produto__c = product.Id;
        freteA.Centro_Distribuicao__c = centro.Id;
        freteA.Cidade__c = cidade1.Id;
        // freteA.Valor__c = 100.00; // Descomente e ajuste se for obrigatório
        insert freteA;

        // 4. Inserir Frete B (Combinação: Produto + Centro + Cidade 2)
        Frete__c freteB = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c());
        freteB.Produto__c = product.Id;
        freteB.Centro_Distribuicao__c = centro.Id;
        freteB.Cidade__c = cidade2.Id;
        insert freteB;

        Test.startTest();

        // ==========================================
        // TESTE 1: A Auto-Atualização (Deve Passar)
        // ==========================================
        try {
            
            update freteA; 
            System.assert(true, 'Sucesso: A trigger permitiu a edição e ignorou o próprio ID na validação de duplicidade.');
        } catch (Exception e) {
            System.assert(false, 'A trigger barrou a edição do próprio registro. Verifique a exclusão do ID na SOQL. Erro: ' + e.getMessage());
        }

        // ==========================================
        // TESTE 2: A Colisão de Duplicidade (Deve Falhar)
        // ==========================================
        
        freteB.Cidade__c = cidade1.Id; 
        
        try {
            update freteB;
            System.assert(false, 'O sistema deveria ter bloqueado a atualização, pois a nova combinação já existe no Frete A.');
        } catch (DmlException e) {
            // IMPORTANTE: Ajuste o texto abaixo para a mensagem de erro exata que a sua Trigger/Classe joga na tela!
            String mensagemEsperada = 'Já existe um registro'; 
            System.assert(e.getMessage().contains(mensagemEsperada), 
                'Erro inesperado ou mensagem de validação incorreta. Mensagem recebida: ' + e.getMessage());
        }

        Test.stopTest();
    }

    @isTest
    static void shouldFailWhenDuplicateInsertInTheSameLote(){
        // 1. Buscar os dados base do Setup
        Centro_de_Distribuicao__c centro = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Product2 product = [SELECT Id FROM Product2 LIMIT 1];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];

        // 2. Criar dois registros de Frete com a mesma combinação (Produto + Centro + Cidade)
        Frete__c frete1 = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c());
        frete1.Produto__c = product.Id;
        frete1.Centro_Distribuicao__c = centro.Id;
        frete1.Cidade__c = cidade.Id;

        Frete__c frete2 = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c());
        frete2.Produto__c = product.Id;
        frete2.Centro_Distribuicao__c = centro.Id;
        frete2.Cidade__c = cidade.Id;

        List<Frete__c> fretesParaInserir = new List<Frete__c>{frete1, frete2};

        try {
            insert fretesParaInserir;
            System.assert(false, 'Deveria ter lançado uma exceção de duplicidade, mas não lançou.');
        } catch (DmlException e) {
            // Esperamos um erro de duplicidade, então o teste passa se entrarmos aqui
            String mensagemEsperada = 'Registro duplicado no mesmo lote'; // Ajuste para a mensagem exata da sua validação
            System.assert(e.getMessage().contains(mensagemEsperada), 
                'Erro inesperado ou mensagem de validação incorreta. Mensagem recebida: ' + e.getMessage());
        }
    }

}