@isTest
private class FreteSelectorTest {

    @testSetup
    static void setupTestData() {

        Id pricebookId = Test.getStandardPricebookId();
        update new Pricebook2(Id = pricebookId, IsActive = true);
        
        // Usa sua Factory para criar a base
        Centro_de_Distribuicao__c cd = (Centro_de_Distribuicao__c) TestFactorySObject.getInstance().createSObject(new Centro_de_Distribuicao__c());
        insert cd;

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
    static void shouldMapAll6FreightCombinations() {
        // 1. Busca os dados do Setup
        Centro_de_Distribuicao__c cd = [SELECT Id FROM Centro_de_Distribuicao__c LIMIT 1];
        Hierarquia_Produto__c hierarquia = [SELECT Id FROM Hierarquia_Produto__c LIMIT 1];
        Product2 produto = [SELECT Id FROM Product2 LIMIT 1];
        Pais__c pais = [SELECT Id FROM Pais__c LIMIT 1];
        Estado__c estado = [SELECT Id FROM Estado__c LIMIT 1];
        Cidade__c cidade = [SELECT Id FROM Cidade__c LIMIT 1];

        // 2. Criar as 6 Variações de Frete usando o método auxiliar
        List<Frete__c> fretesParaInserir = new List<Frete__c>();

        // O CD é padrão e sempre passado como o primeiro parâmetro

        // --- COMBINAÇÕES COM PRODUTO ---
        // (CD, Produto, Hierarquia, Cidade, Estado, Pais)
        fretesParaInserir.add(criarFreteHelper(cd.Id, produto.Id, null, cidade.Id, null, null)); // 1. Prod + Cidade
        fretesParaInserir.add(criarFreteHelper(cd.Id, produto.Id, null, null, estado.Id, null)); // 2. Prod + Estado
        fretesParaInserir.add(criarFreteHelper(cd.Id, produto.Id, null, null, null, pais.Id));   // 3. Prod + Pais

        // --- COMBINAÇÕES COM HIERARQUIA ---
        fretesParaInserir.add(criarFreteHelper(cd.Id, null, hierarquia.Id, cidade.Id, null, null)); // 4. Hier + Cidade
        fretesParaInserir.add(criarFreteHelper(cd.Id, null, hierarquia.Id, null, estado.Id, null)); // 5. Hier + Estado
        fretesParaInserir.add(criarFreteHelper(cd.Id, null, hierarquia.Id, null, null, pais.Id));   // 6. Hier + Pais

        insert fretesParaInserir;

        // 3. Prepara os Sets para o Selector
        Set<Id> produtosIds = new Set<Id>{ produto.Id };
        Set<Id> hierarquiasIds = new Set<Id>{ hierarquia.Id };
        Set<Id> cdsIds = new Set<Id>{ cd.Id };
        Set<Id> locaisIds = new Set<Id>{ cidade.Id, estado.Id, pais.Id }; 

        // 4. Executa a Classe
        Test.startTest();
        Map<String, Frete__c> mapaRetornado = FreteSelector.getMapaRegras(produtosIds, hierarquiasIds, locaisIds, cdsIds);
        Test.stopTest();

        // 5. Validações de Quantidade
        Assert.areEqual(6, mapaRetornado.size(), 'O mapa deveria conter exatamente as 6 combinações exclusivas de frete.');

        // 6. Validação Específica de cada Chave Gerada
        Assert.isTrue(mapaRetornado.containsKey(String.valueOf(produto.Id) + String.valueOf(cidade.Id)), 'Faltou a chave: Prod + Cidade');
        Assert.isTrue(mapaRetornado.containsKey(String.valueOf(produto.Id) + String.valueOf(estado.Id)), 'Faltou a chave: Prod + Estado');
        Assert.isTrue(mapaRetornado.containsKey(String.valueOf(produto.Id) + String.valueOf(pais.Id)), 'Faltou a chave: Prod + Pais');
        
        Assert.isTrue(mapaRetornado.containsKey(String.valueOf(hierarquia.Id) + String.valueOf(cidade.Id)), 'Faltou a chave: Hierarquia + Cidade');
        Assert.isTrue(mapaRetornado.containsKey(String.valueOf(hierarquia.Id) + String.valueOf(estado.Id)), 'Faltou a chave: Hierarquia + Estado');
        Assert.isTrue(mapaRetornado.containsKey(String.valueOf(hierarquia.Id) + String.valueOf(pais.Id)), 'Faltou a chave: Hierarquia + Pais');
    }

    // ==========================================
    // MÉTODO AUXILIAR
    // ==========================================
    private static Frete__c criarFreteHelper(Id cdId, Id prodId, Id hierId, Id cidId, Id estId, Id paisId) {
        Frete__c f = (Frete__c) TestFactorySObject.getInstance().createSObject(new Frete__c());
        
        // CD é o campo padrão fixo
        f.Centro_Distribuicao__c = cdId;
        f.Status__c = 'Aprovado';
        
        // Aplica o XOR nos alvos
        f.Produto__c = prodId;
        f.Hierarquia_Produto__c = hierId;
        
        // Aplica o XOR na geografia
        f.Cidade__c = cidId;
        f.Estado__c = estId;
        f.Pais__c = paisId;
        
        return f;
    }
}