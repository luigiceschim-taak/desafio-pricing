# Como criar a scratch org e migrar dados da pricingOrg

Guia passo a passo para recriar o ambiente de desenvolvimento do Pricing Dashboard do zero.

---

## Pré-requisitos

- Salesforce CLI v2.x instalado (`sf --version`)
- DevHub ativado na `pricingOrg` (Setup → Dev Hub → Enable)
- `pricingOrg` configurada como Dev Hub: `sf config set target-dev-hub pricingOrg`

---

## 1. Configurar o scratch org definition

O arquivo `config/project-scratch-def.json` precisa ter:

```json
{
  "orgName": "Pricing Dashboard Dev",
  "edition": "Developer",
  "language": "en_US",
  "features": ["EnableSetPasswordInApi", "MultiCurrency"],
  "settings": {
    "lightningExperienceSettings": {
      "enableS1DesktopEnabled": true
    },
    "UIBundleSettings": {
      "webAppOptIn": true
    },
    "mobileSettings": {
      "enableS1EncryptedStoragePref2": false
    }
  }
}
```

**Por que `MultiCurrency`?** A `pricingOrg` tem multi-currency ativado. Os campos custom de `OrderItem` (FreightCost__c, etc.) são do tipo `Currency` e `Percent` — sem a feature `MultiCurrency` na scratch org esses campos ficam invisíveis no schema do Apex, mesmo após o deploy.

**Por que `UIBundleSettings.webAppOptIn: true`?** Habilita o suporte ao metadata type `UIBundle` (Salesforce Multi-Framework). Sem isso, o deploy do app React falha.

**Por que `language: en_US`?** O Multi-Framework Beta só funciona em orgs com inglês como idioma padrão.

---

## 2. Criar a scratch org

```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --target-dev-hub pricingOrg \
  --alias pricingDashboardScratch \
  --duration-days 30 \
  --set-default
```

---

## 3. Deploy dos campos custom de OrderItem

Os objetos completos (Account, Order, etc.) falham no deploy porque referenciam `CurrencyIsoCode` como campo custom — um artefato da configuração de multi-currency da `pricingOrg`. O workaround é deployar **somente os campos custom** que o app usa:

```bash
sf project deploy start \
  --metadata "CustomField:OrderItem.FreightCost__c" \
  --metadata "CustomField:OrderItem.MarginPercentage__c" \
  --metadata "CustomField:OrderItem.TaxPercentage__c" \
  --metadata "CustomField:OrderItem.ProductionCost__c" \
  --metadata "CustomField:OrderItem.TotalSellingPrice__c" \
  --metadata "CustomField:OrderItem.IdealPrice__c" \
  --metadata "CustomField:OrderItem.TotalIdealPrice__c" \
  --metadata "CustomField:OrderItem.SurplusMargin__c" \
  --metadata "CustomField:OrderItem.ProductDiscount__c" \
  --metadata "CustomField:OrderItem.ExternalId__c" \
  --target-org pricingDashboardScratch
```

> **Nota:** `ExternalId__c` é obrigatório e único no `OrderItem` — necessário para o seed de dados.

---

## 4. Deploy e atribuição do Permission Set

Os campos Currency/Percent ficam invisíveis em SOQL sem FLS (Field Level Security) explícita:

```bash
# Deploy do permission set
sf project deploy start \
  --metadata "PermissionSet:PricingDashboardAccess" \
  --target-org pricingDashboardScratch

# Atribuir ao usuário da scratch org
sf org assign permset \
  --name PricingDashboardAccess \
  --target-org pricingDashboardScratch
```

O arquivo está em `force-app/main/default/permissionsets/PricingDashboardAccess.permissionset-meta.xml`.

---

## 5. Deploy do UI Bundle (app React)

```bash
# Build primeiro
cd force-app/main/default/uiBundles/PricingDashboard
npm install && npm run build
cd ../../../../..  # volta para raiz do projeto

# Deploy
sf project deploy start \
  --source-dir force-app/main/default/uiBundles \
  --target-org pricingDashboardScratch
```

---

## 6. Seed de dados da pricingOrg

O script `scripts/data/seed_scratch_org.apex` recria na scratch org os mesmos 20 Orders e 30 OrderItems da `pricingOrg`, com os campos de pricing preenchidos.

```bash
sf apex run \
  --file scripts/data/seed_scratch_org.apex \
  --target-org pricingDashboardScratch
```

O script cria:
- 1 Account (`Agro External Integration Account`)
- 2 Products (`Product 001` e `Product 002`)
- PricebookEntries no Pricebook padrão
- 20 Orders com status `Activated`
- 30 OrderItems com `FreightCost__c`, `MarginPercentage__c`, `TaxPercentage__c`, `ProductionCost__c` e `ExternalId__c`

> Os campos formula (`IdealPrice__c`, `TotalSellingPrice__c`, `TotalIdealPrice__c`, `SurplusMargin__c`, `ProductDiscount__c`) são calculados automaticamente — não precisam de seed.

---

## 7. Abrir a org no browser

```bash
sf org open --target-org pricingDashboardScratch
```

---

## Script completo (do zero)

```bash
# A partir da raiz do projeto desafio-pricing

# 1. Criar scratch org
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --target-dev-hub pricingOrg \
  --alias pricingDashboardScratch \
  --duration-days 30 \
  --set-default

# 2. Deploy campos custom
sf project deploy start \
  --metadata "CustomField:OrderItem.FreightCost__c" \
  --metadata "CustomField:OrderItem.MarginPercentage__c" \
  --metadata "CustomField:OrderItem.TaxPercentage__c" \
  --metadata "CustomField:OrderItem.ProductionCost__c" \
  --metadata "CustomField:OrderItem.TotalSellingPrice__c" \
  --metadata "CustomField:OrderItem.IdealPrice__c" \
  --metadata "CustomField:OrderItem.TotalIdealPrice__c" \
  --metadata "CustomField:OrderItem.SurplusMargin__c" \
  --metadata "CustomField:OrderItem.ProductDiscount__c" \
  --metadata "CustomField:OrderItem.ExternalId__c" \
  --target-org pricingDashboardScratch

# 3. Deploy permission set + atribuir
sf project deploy start \
  --metadata "PermissionSet:PricingDashboardAccess" \
  --target-org pricingDashboardScratch
sf org assign permset --name PricingDashboardAccess --target-org pricingDashboardScratch

# 4. Build + deploy UI Bundle
cd force-app/main/default/uiBundles/PricingDashboard && npm install && npm run build && cd ../../../../..
sf project deploy start --source-dir force-app/main/default/uiBundles --target-org pricingDashboardScratch

# 5. Seed de dados
sf apex run --file scripts/data/seed_scratch_org.apex --target-org pricingDashboardScratch

# 6. Abrir
sf org open --target-org pricingDashboardScratch
```

---

## 8. Definir senha para acesso manual

Por padrão a scratch org não tem senha. Para criar uma:

```bash
sf org generate password --target-org pricingDashboardScratch
```

Para ver a senha novamente depois:

```bash
sf org display user --target-org pricingDashboardScratch
```

---

## 9. Rodar localmente com dados reais da org

`npm run dev` sozinho **não autentica com a org** — o SDK não tem sessão e cai no mock. Para rodar com dados reais localmente:

```bash
cd force-app/main/default/uiBundles/PricingDashboard
npm run dev:org   # SF_ORG=pricingDashboardScratch vite
```

O script `dev:org` passa o alias via `SF_ORG` para o plugin `@salesforce/vite-plugin-ui-bundle`, que cria um proxy local autenticado com a org. O app em `http://localhost:5173` usa dados reais da scratch org.

Para usar outra org:
```bash
SF_ORG=outraOrg npm run dev
```

---

## Bug conhecido e resolvido: GraphQL retornava undefined

O `@salesforce/sdk-data` espera **um objeto** como argumento do método `graphql`:

```ts
// Errado (chamada com dois argumentos)
sdk.graphql(query, variables)

// Correto (objeto único)
sdk.graphql({ query, variables })
```

Esse bug fazia o SDK retornar `undefined`, o `graphqlClient.ts` lançava exceção, e o app caía no mock data. Corrigido em `src/api/graphqlClient.ts`.

---

## Por que não funciona na pricingOrg diretamente?

A `pricingOrg` é uma Developer Edition. Para usar o UI Bundle (React + Multi-Framework), é necessário ativar manualmente em:

**Setup → Apps → React Development with Agentforce Vibes and Salesforce Multi-Framework (Beta)**

Clique em **Enable Beta** → **Enable** (atenção: não pode ser desfeito).

Depois o deploy funciona direto na `pricingOrg` sem precisar de scratch org.

---

## Por que não dá para importar os dados diretamente com `sf data export tree`?

O `sf data export tree` exporta os registros com os IDs reais da `pricingOrg` (AccountId, Pricebook2Id). No import, esses IDs não existem na scratch org — o import falha. A solução foi gerar um script Apex anônimo que cria os registros do zero na scratch org com os valores certos.

---

## Arquivos relevantes

| Arquivo | Descrição |
|---------|-----------|
| `config/project-scratch-def.json` | Definição da scratch org (MultiCurrency + UIBundle) |
| `force-app/main/default/permissionsets/PricingDashboardAccess.permissionset-meta.xml` | FLS para campos de pricing no OrderItem |
| `scripts/data/seed_scratch_org.apex` | Script Apex de seed dos dados |
| `force-app/main/default/uiBundles/PricingDashboard/` | App React (Pricing Dashboard) |
| `force-app/main/default/uiBundles/PricingDashboard/src/api/graphqlClient.ts` | Cliente GraphQL com correção do bug do SDK (objeto único) |
| `docs/react-tailwind-shadcn-salesforce.md` | Guia geral sobre Multi-Framework |
