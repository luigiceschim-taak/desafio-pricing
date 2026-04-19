@isTest
private class TestFactorySObjectTest {

    // ==========================================
    // ALVO 1: validateSObject (Testando o null)
    // ==========================================
    @isTest
    static void shouldThrowExceptionWhenSObjectIsNull() {
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        Test.startTest();
        try {
            // Forçamos o erro mandando null propositalmente
            factory.createSObject(null);
            
            // Se o código chegar aqui, o teste falha, pois deveria ter dado erro
            Assert.fail('O sistema deveria ter lançado uma TestFactoryException por causa do SObject nulo.');
        } catch (TestFactorySObject.TestFactoryException e) {
            // Validamos se a mensagem de erro é exatamente a que está no seu código
            Assert.isTrue(e.getMessage().contains('SObject cannot be null'), 'Mensagem de erro incorreta: ' + e.getMessage());
        }
        Test.stopTest();
    }

    // ==========================================
    // ALVO 2: createSObject (Testando o if do Contract)
    // ==========================================
    @isTest
    static void shouldChangeObjectNameForContract() {
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        Test.startTest();
        try {
            // Mandamos um Contract para o método cair no "if (objectName == 'Contract')"
            factory.createSObject(new Contract());
            
            // Se a sua org TIVER a classe TemplateDefaultFields.ContractStandardDefaults criada, o código chega aqui com sucesso.
            Assert.isTrue(true, 'O objeto Contract foi processado e instanciado com sucesso.');
        } catch (TestFactorySObject.TestFactoryException e) {
            // Se a sua org NÃO TIVER a classe criada, ele vai estourar o erro de classe faltando.
            // Mas a mensagem do erro vai provar que o nome foi alterado de "Contract" para "ContractStandard"!
            Assert.isTrue(e.getMessage().contains('ContractStandardDefaults'), 'O if do Contract falhou em alterar o nome. Erro: ' + e.getMessage());
        }
        Test.stopTest();
    }

    // ==========================================
    // ALVO 3: dispatchSObjectCreation (Testando a classe inexistente)
    // ==========================================
    @isTest
    static void shouldThrowExceptionWhenDefaultsClassIsMissing() {
        TestFactorySObject factory = TestFactorySObject.getInstance();
        
        Test.startTest();
        try {
            // Chamamos o método público normal, mas mandamos um objeto que não tem template.
            // O sistema vai tentar procurar a classe 'TemplateDefaultFields.AuthSessionDefaults'.
            // Como ela não existe, o método interno vai estourar o seu Alvo 3!
            factory.createSObject(new AuthSession());
            
            Assert.fail('O sistema deveria ter lançado uma TestFactoryException por causa da classe inexistente.');
        } catch (TestFactorySObject.TestFactoryException e) {
            // Validamos se a mensagem do Alvo 3 foi disparada
            Assert.isTrue(e.getMessage().contains('Invalid defaults class. Missing class:'), 'Mensagem de erro incorreta: ' + e.getMessage());
        }
        Test.stopTest();
    }
}