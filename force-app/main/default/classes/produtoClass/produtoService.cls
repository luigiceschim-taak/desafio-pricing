public with sharing class produtoService {
    public static void createPriceBookEntry(List<Product2> newProducts) {

       List<Pricebook2> priceBookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
    
        

        
      

        // 3. Verificação de Segurança
        if (priceBookId.isEmpty()) {
            for (Product2 p : newProducts) {
                // O addError impede o DML e mostra a mensagem na tela/API
                p.addError('Não foi possível criar o produto: Nenhum Pricebook (Tabela de Preços) ativo foi encontrado no sistema.');
            }
            return; // Interrompe a execução pois não há ID para continuar
        }

        List<PricebookEntry> priceBookEntriesToInsert = new List<PricebookEntry>();

        List<CurrencyType> ct = [SELECT IsoCode FROM CurrencyType WHERE IsActive = true];
        Id priceBook = priceBookId[0].Id; // Pega o ID do Pricebook padrão
        
        
        

       for(Product2 p : newProducts) {
            for(CurrencyType c : ct) {
               
                PricebookEntry pbe = new PricebookEntry();
                pbe.Pricebook2Id = priceBook;
                pbe.Product2Id = p.Id;
                pbe.UnitPrice = p.Custo_Producao__c;
                pbe.IsActive = true;
                pbe.CurrencyIsoCode = c.IsoCode;
                
                priceBookEntriesToInsert.add(pbe);
            }
        }
        System.debug('--------------------------------------');

        System.debug('PRICEBOOK PARA SER INSERIDO!!!!!: ' + priceBookEntriesToInsert);

        System.debug('--------------------------------------');


        if(!priceBookEntriesToInsert.isEmpty()) {
            try{
            insert priceBookEntriesToInsert;
            } catch (DmlException e) {
                System.debug('Error inserting PriceBookEntries: ' + e.getMessage());
            }
        }    
    }

    

}