@isTest
private class MargemSelectorTest {

    @testSetup
    static void setupTestData() {

        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);
        // 1. Dados de Produto
        Hierarquia_Produto__c hierarquia = (Hierarquia_Produto__c) TestFactorySObject.getInstance().createSObject(new Hierarquia_Produto__c());
        insert hierarquia;

        Product2 produto = (Product2) TestFactorySObject.getInstance().createSObject(new Product2());
        produto.Hierarquia_Produto__c = hierarquia.Id;
        insert produto;

        // 2. Dados de Cliente
        Grupo_Conta__c grupo = (Grupo_Conta__c) TestFactorySObject.getInstance().createSObject(new Grupo_Conta__c());
        insert grupo;

        Account conta = (Account) TestFactorySObject.getInstance().createSObject(new Account());
        conta.Grupo_Clientes__c = grupo.Id;
        insert conta;

        // 3. Dados Geográficos
        Pais__c pais = (Pais__c) TestFactorySObject.getInstance().createSObject(new Pais__c());
        insert pais;

        Estado__c estado = (Estado__c) TestFactorySObject.getInstance().createSObject(new Estado__c());
        estado.Pais__c = pais.Id;
        insert estado;
        
        Cidade__c cidade = (Cidade__c) TestFactorySObject.getInstance().createSObject(new Cidade__c());
        cidade.Estado__c = estado.Id;
        insert cidade;

        // 4. Centro de Distribuição
        Centro_de_Distribuicao__c cd = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert cd;
    }

    @isTest
    static void shouldMapAll12MargemCombinations() {
        // 1. Busca os dados do Setup
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Hierarquia_Produto__c hierarquia = [SELECT Id FROM Hierarquia_Produto__c LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Grupo_Conta__c grupo = [SELECT Id FROM Grupo_Conta__c LIMIT 1];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];

        // 2. Listas de Permutação
        List<Id> opcoesProduto = new List<Id>{ produto.Id, hierarquia.Id };
        List<Id> opcoesConta = new List<Id>{ conta.Id, grupo.Id };
        List<Id> opcoesGeo = new List<Id>{ cidade.Id, estado.Id, pais.Id };

        List<Margem__c> margensParaInserir = new List<Margem__c>();

        // 3. Gerador Automático de Combinações (12 Variações)
        for (Id pAlvo : opcoesProduto) {
            for (Id cAlvo : opcoesConta) {
                for (Id gAlvo : opcoesGeo) {
                    margensParaInserir.add(criarMargemHelper(
                        (pAlvo == produto.Id) ? produto.Id : null,
                        (pAlvo == hierarquia.Id) ? hierarquia.Id : null,
                        (cAlvo == conta.Id) ? conta.Id : null,
                        (cAlvo == grupo.Id) ? grupo.Id : null,
                        (gAlvo == cidade.Id) ? cidade.Id : null,
                        (gAlvo == estado.Id) ? estado.Id : null,
                        (gAlvo == pais.Id) ? pais.Id : null,
                        cd.Id
                    ));
                }
            }
        }
        insert margensParaInserir;

        // ================================================================
        // 4. PREPARAÇÃO DOS SETS (O SEGREDO DA SUA NOVA ESTRUTURA ESTÁ AQUI)
        // ================================================================
        
        // Colocamos Produto e Hierarquia no MESMO Set, conforme sua nova classe espera!
        Set<Id> produtosIds = new Set<Id>{ produto.Id, hierarquia.Id };
        
        Set<Id> contasIds = new Set<Id>{ conta.Id };
        Set<Id> gruposIds = new Set<Id>{ grupo.Id };
        Set<Id> locaisIds = new Set<Id>{ cidade.Id, estado.Id, pais.Id }; 
        Set<Id> cdsIds = new Set<Id>{ cd.Id };

        // 5. Executa a Classe com os 5 Parâmetros
        Test.startTest();
        Map<String, Margem__c> mapaRetornado = margemSelector.getMapaRegras(produtosIds, locaisIds, cdsIds, contasIds, gruposIds);
        Test.stopTest();

        // 6. Validações
        Assert.areEqual(12, mapaRetornado.size(), 'Deveria conter exatamente as 12 combinações.');

        for (Id pAlvo : opcoesProduto) {
            for (Id cAlvo : opcoesConta) {
                for (Id gAlvo : opcoesGeo) {
                    // Reconstrói a chave conforme a sua regra: Produto + Conta + CD + Geografia
                    String chaveEsperada = String.valueOf(pAlvo) + String.valueOf(cAlvo) + String.valueOf(cd.Id) + String.valueOf(gAlvo);

                    Assert.isTrue(mapaRetornado.containsKey(chaveEsperada), 
                        'Falhou ao mapear a chave: ' + chaveEsperada);
                }
            }
        }
    }

    @isTest 
    static void shouldFailWhenInsertDuplicateInTheLote() {
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Hierarquia_Produto__c hierarquia = [SELECT Id FROM Hierarquia_Produto__c LIMIT 1];
        Account conta = [SELECT Id FROM Account LIMIT 1];
        Grupo_Conta__c grupo = [SELECT Id FROM Grupo_Conta__c LIMIT 1];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];

        List<Margem__c> margensParaInserir = new List<Margem__c>();

        // Criamos 2 regras idênticas de propósito para testar a falha
        margensParaInserir.add(criarMargemHelper(produto.Id, null, conta.Id, null, cidade.Id, null, null, cd.Id));
        margensParaInserir.add(criarMargemHelper(produto.Id, null, conta.Id, null, cidade.Id, null, null, cd.Id));

        try {
            insert margensParaInserir;
            Assert.fail('Deveria ter lançado uma exceção de duplicidade, mas não lançou.');
        } catch (DmlException e) {
            // Esperamos um erro de duplicidade, então o teste passa se entrarmos aqui
            System.debug('Exceção capturada como esperado: ' + e.getMessage());
        }
    }

    // ==========================================
    // MÉTODO AUXILIAR
    // ==========================================
    private static Margem__c criarMargemHelper(Id prodId, Id hierId, Id contaId, Id grupoId, Id cidId, Id estId, Id paisId, Id cdId) {
        Margem__c m = (Margem__c) TestFactorySObject.getInstance().createSObject(new Margem__c());
        
        m.Status__c = 'Aprovado';
        m.Centro_Distribuicao__c = cdId;

        m.Produto__c = prodId;
        m.Hierarquia_Produto__c = hierId;
        
        m.Conta__c = contaId;
        m.Grupo_Conta__c = grupoId;

        m.Cidade__c = cidId;
        m.Estado__c = estId;
        m.Pais__c = paisId;
        
        return m;
    }
}