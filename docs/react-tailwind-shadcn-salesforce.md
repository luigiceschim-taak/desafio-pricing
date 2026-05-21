# React + Tailwind CSS + shadcn/ui no Salesforce

Guia de estudo completo sobre como usar o stack moderno de frontend dentro do ecossistema Salesforce.

---

## Sumário

1. [A distinção mais importante: Apps vs Componentes](#a-distinção-mais-importante-apps-vs-componentes)
2. [É possível?](#é-possível)
3. [Path A — Salesforce Multi-Framework (React nativo)](#path-a--salesforce-multi-framework)
4. [Path B — LWC + Tailwind CSS (sem React)](#path-b--lwc--tailwind-css)
5. [Comparativo das abordagens](#comparativo)
6. [Arquitetura do Multi-Framework](#arquitetura-do-multi-framework)
7. [Como começar (Path A)](#como-começar-path-a)
8. [Como começar (Path B)](#como-começar-path-b)
9. [Limitações e riscos](#limitações-e-riscos)
10. [Referências completas](#referências-completas)

---

## A distinção mais importante: Apps vs Componentes

Antes de qualquer coisa, entenda a diferença entre **criar um app** e **criar um componente** no Salesforce — porque isso determina o que é possível hoje.

| O que você quer fazer | Possível hoje? | Stack disponível |
|-----------------------|----------------|-----------------|
| **App standalone** (página própria, abre pelo App Launcher) | Sim — Open Beta | React + Tailwind + shadcn/ui |
| **Componente React dentro de uma Lightning record page** (ex: na página de Order) | Não — Spring 2027 | Micro-frontend em closed pilot |
| **Componente com Tailwind** dentro de uma Lightning record page hoje | Sim — Produção | LWC + Tailwind (sem React, sem shadcn) |

### O que isso significa na prática

O **Multi-Framework** (Path A) cria **apps completos e isolados**. O app React fica em uma página separada, como se fosse uma nova aba no Salesforce — ele aparece no App Launcher igual a qualquer outro app nativo. Dentro desse app, você pode criar quantos componentes React quiser, usar shadcn/ui, Tailwind, tudo. Mas ele **não se mistura** com as Lightning pages existentes (record pages, home page, etc).

Para **embutir um componente React diretamente numa Lightning page existente** — por exemplo, adicionar um painel de pricing com shadcn/ui na página do Order — isso é chamado de **micro-frontend** e está em closed pilot. A Salesforce prevê GA para Spring 2027.

Enquanto isso, se precisar de **componentes dentro de Lightning pages hoje**, a única opção viável é **LWC + Tailwind** (Path B), sem React e sem shadcn.

```
HOJE (maio 2026)
─────────────────────────────────────────────────────────────
Lightning Record Page    │    App Launcher
─────────────────────────│─────────────────────────────────
[LWC + Tailwind] ✅      │    [React + Tailwind + shadcn] ✅
[React + shadcn] ❌      │    (UI Bundle — página separada)
─────────────────────────────────────────────────────────────

SPRING 2027
─────────────────────────────────────────────────────────────
Lightning Record Page    │    App Launcher
─────────────────────────│─────────────────────────────────
[LWC + Tailwind] ✅      │    [React + Tailwind + shadcn] ✅
[React + shadcn] ✅      │
(micro-frontend GA)      │
─────────────────────────────────────────────────────────────
```

---

## É possível?

**Sim.** A partir de abril de 2026, o Salesforce anunciou suporte oficial a React no evento TDX com o lançamento do **Salesforce Multi-Framework**. Antes disso, já era possível usar Tailwind CSS dentro de LWCs via Static Resources. O shadcn/ui (biblioteca de componentes React) funciona apenas na abordagem com Multi-Framework — e apenas em apps standalone, não em componentes de Lightning pages por enquanto.

---

## Path A — Salesforce Multi-Framework

### O que é

O Salesforce Multi-Framework é um runtime agnóstico de framework dentro da Agentforce 360 Platform. Ele permite construir apps React que rodam nativamente no Salesforce, com autenticação, segurança e governança já embutidos — sem precisar gerenciar tokens ou configurar CORS.

### O que vem pré-configurado no template

Ao rodar `sf template generate ui-bundle`, o template gerado já inclui:

- **Vite** — bundler e dev server (porta `localhost:5173`)
- **TypeScript** — suporte nativo
- **Tailwind CSS v4** — configurado via `tailwind.config.ts`
- **shadcn/ui** — configurado via `components.json`
- **`@salesforce/sdk-data`** — SDK para acessar dados do Salesforce

### Novo tipo de metadado: UI Bundle

Os apps React são empacotados como **UI Bundles**, um novo tipo de metadado Salesforce:

```
force-app/main/default/uiBundles/
└── meu-app/
    ├── src/
    │   ├── App.tsx
    │   ├── components/
    │   └── pages/
    ├── tailwind.config.ts
    ├── components.json
    ├── vite.config.ts
    └── package.json
```

### Como o app acessa dados do Salesforce

O SDK `@salesforce/sdk-data` substitui o `@wire` do LWC. Ele oferece:

```ts
import { createDataSDK } from '@salesforce/sdk-data';

const sdk = createDataSDK(); // autenticação automática, sem token manual

// Chamar um método Apex
const result = await sdk.apex.invoke('OrderItemService.getItems', { orderId });

// Query GraphQL (UI API)
const data = await sdk.graphql.query(`
  query {
    uiapi {
      query {
        Order {
          edges {
            node { Id Name Status }
          }
        }
      }
    }
  }
`);
```

### Status atual (maio 2026)

| Feature | Status |
|---------|--------|
| Open Beta (scratch orgs e sandboxes) | Disponível |
| Produção | Indisponível durante beta |
| Orgs em inglês (default language) | Obrigatório no beta |
| Micro-frontend (embed em Lightning pages) | Closed pilot |
| Drag-and-drop no Lightning App Builder | Previsto para Spring 2027 |

---

## Path B — LWC + Tailwind CSS

### O que é

Abordagem estável e disponível para produção hoje. Não usa React — fica dentro da arquitetura LWC padrão. O shadcn/ui **não é compatível** aqui (é uma biblioteca React).

### Como funciona

Como o Salesforce não tem runtime Node.js, o Tailwind CSS é compilado localmente e depois enviado como Static Resource.

### Passo a passo

**1. Compilar o CSS localmente**

```bash
npx tailwindcss -i ./input.css -o ./output.css --minify
```

**2. Salvar na pasta de static resources**

```
force-app/main/default/staticresources/
└── tailwind.css
└── tailwind.resource-meta.xml
```

**3. Carregar no componente LWC**

```js
// myComponent.js
import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import TAILWIND from '@salesforce/resourceUrl/tailwind';

export default class MyComponent extends LightningElement {
    connectedCallback() {
        loadStyle(this, TAILWIND);
    }
}
```

**4. Usar as classes no template**

```html
<!-- myComponent.html -->
<template>
    <div class="flex items-center gap-4 p-6 bg-white rounded-xl shadow">
        <h1 class="text-2xl font-bold text-slate-800">Olá, Salesforce!</h1>
    </div>
</template>
```

### Limitações

- Rebuild manual toda vez que o `tailwind.config` mudar
- Redeploy obrigatório após cada alteração de CSS
- Sem shadcn/ui
- Tamanho do arquivo: manter enxuto, só utilities necessários

---

## Comparativo

| Critério | Path A (Multi-Framework) | Path B (LWC + Tailwind) |
|----------|--------------------------|-------------------------|
| React | Sim | Não |
| Tailwind CSS | Sim (nativo) | Sim (via Static Resource) |
| shadcn/ui | Sim | Não |
| Produção | Não (beta) | Sim |
| Dev server local | Sim (Vite) | Não |
| Acesso a dados | `@salesforce/sdk-data` | `@wire`, Apex |
| Complexidade de setup | Baixa (template CLI) | Média (build manual) |
| Maturidade | Beta (abr 2026) | Estável |

---

## Arquitetura do Multi-Framework

```
┌─────────────────────────────────────────────────────────────┐
│                    Salesforce Platform                       │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Agentforce 360 Runtime                  │   │
│  │                                                      │   │
│  │   ┌─────────────────────────────────────────────┐   │   │
│  │   │           React App (UI Bundle)              │   │   │
│  │   │                                              │   │   │
│  │   │   src/App.tsx                                │   │   │
│  │   │   ├── components/  (shadcn/ui)               │   │   │
│  │   │   └── pages/                                 │   │   │
│  │   │                                              │   │   │
│  │   │   @salesforce/sdk-data                       │   │   │
│  │   │   ├── sdk.apex.invoke()   ──────────────────────→ Apex Classes   │
│  │   │   └── sdk.graphql.query() ──────────────────────→ GraphQL/UI API │
│  │   └─────────────────────────────────────────────┘   │   │
│  │                                                      │   │
│  │   Auth & Security: automático, sem token mgmt        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## Como começar (Path A)

### Pré-requisitos

- Salesforce CLI v2.x (`sf --version`)
- Node.js 18+
- Dev Hub habilitado (para scratch orgs)
- Sandbox ou scratch org com Multi-Framework habilitado

### Comandos

```bash
# 1. Gerar o template do UI Bundle
sf template generate ui-bundle

# 2. Entrar na pasta do app
cd force-app/main/default/uiBundles/<nome-do-app>

# 3. Instalar dependências
npm install

# 4. Rodar localmente
npm run dev
# → app disponível em http://localhost:5173

# 5. Adicionar componentes shadcn/ui
npx shadcn@latest add button
npx shadcn@latest add card
npx shadcn@latest add table
npx shadcn@latest add dialog

# 6. Deploy para sandbox
sf project deploy start
```

### Alternativa via Agentforce Vibes (UI)

No menu de boas-vindas do **Agentforce Vibes**, clique em:
- **React App** tile → **Internal App** → gera o projeto automaticamente

---

## Como começar (Path B)

```bash
# 1. Criar arquivo de entrada do Tailwind
echo '@tailwind base; @tailwind components; @tailwind utilities;' > input.css

# 2. Compilar
npx tailwindcss -i ./input.css \
  -o ./force-app/main/default/staticresources/tailwind.css \
  --minify

# 3. Criar o meta XML da static resource
# force-app/main/default/staticresources/tailwind.resource-meta.xml
# <?xml version="1.0" encoding="UTF-8"?>
# <StaticResource xmlns="http://soap.sforce.com/2006/04/metadata">
#     <cacheControl>Public</cacheControl>
#     <contentType>text/css</contentType>
# </StaticResource>

# 4. Deploy
sf project deploy start \
  --source-dir force-app/main/default/staticresources/tailwind.css
```

---

## Limitações e riscos

### Multi-Framework (Path A)

- **Beta ≠ Produção:** Não use em orgs produtivas ainda.
- **Idioma:** Somente orgs com inglês como idioma padrão no beta.
- **Micro-frontend bloqueado:** Embutir componentes React em Lightning Pages via drag-and-drop só estará disponível em Spring 2027. Por enquanto o app React é uma página separada.
- **Sem `@wire` / LDS:** Toda integração com dados usa `@salesforce/sdk-data`.
- **Algumas Platform APIs indisponíveis:** Ainda não expostas no runtime beta.

### LWC + Tailwind (Path B)

- **Rebuild manual:** Toda mudança no `tailwind.config` exige recompilar e fazer deploy.
- **Sem JIT no Salesforce:** O Tailwind JIT roda localmente, não na plataforma.
- **Tamanho do bundle:** Configurar `content` no `tailwind.config` para purge correto.

---

## Referências completas

### Documentação oficial Salesforce

- [Build with React, Run on Salesforce — Introducing Salesforce Multi-Framework (Blog Oficial, abr 2026)](https://developer.salesforce.com/blogs/2026/04/build-with-react-run-on-salesforce-introducing-salesforce-multi-framework)
- [Salesforce Multi-Framework com React — versão japonesa (Blog Oficial)](https://developer.salesforce.com/blogs/2026/04/salesforce-mult-framework-react-jp)
- [Style with Lightning Design System in LWC (Docs oficiais)](https://developer.salesforce.com/docs/platform/lwc/guide/create-components-css-slds.html)
- [Integrate Salesforce Personalization with Modern Frontend Frameworks (Docs oficiais)](https://developer.salesforce.com/docs/marketing/einstein-personalization/guide/integrate-personalization-modern-frontend-frameworks.html)
- [Algolia — Custom React Frontend with Salesforce Commerce Cloud](https://www.algolia.com/doc/integration/salesforce-commerce-cloud-b2c/guides/custom-react-frontend)

### Salesforce Multi-Framework — artigos e análises

- [Salesforce Multi-Framework: React Is Now a First-Class Citizen on the Platform (salesforcemonday.com)](https://salesforcemonday.com/2026/05/04/salesforce-multi-framework-react-native-platform/)
- [Salesforce Multi-Framework: React Integration & Future of Development — TDX 2026 (awsquality.com)](https://www.awsquality.com/salesforce-goes-multi-framework-and-react-is-just-the-beginning/)
- [Microfrontends with React Inside Salesforce: Lessons from a Real Project (Medium — Lucas Keller)](https://medium.com/@lucaskeller/microfrontends-with-react-inside-salesforce-lessons-from-a-real-project-feff9ec04aa2)
- [How to implement Micro Frontend on Salesforce with React — Experience Cloud (DEV.to)](https://dev.to/arthurkellermann/how-to-implement-micro-frontend-in-salesforce-experience-cloud-59n3)

### Tailwind CSS no LWC (Path B)

- [How to Use Tailwind CSS in Salesforce LWC — The Easy Way (Medium — Zahi Saadieh)](https://medium.com/@zahisaadieh/how-to-use-tailwind-css-in-salesforce-lightning-web-components-lwc-the-easy-way-10fc199a421d)
- [LWC and Tailwind CSS (bluecloud.blog)](https://bluecloud.blog/posts/lwc-and-tailwindcss/)
- [salesforce-community-tailwindcss — Projeto SFDX de exemplo (GitHub — Georg Wittberger)](https://github.com/georgwittberger/salesforce-community-tailwindcss)
- [Conceitos do projeto salesforce-community-tailwindcss (Docs do projeto)](https://georgwittberger.github.io/salesforce-community-tailwindcss/concepts/)

### React vs LWC — entendendo as diferenças

- [LWC (Lightning Web Components) vs. React Components (DEV.to — Nick Warren)](https://dev.to/nickwarren47/lwc-lightning-web-components-vs-react-components-31d1)

### shadcn/ui + React + Tailwind (geral)

- [Build a Lightning-Fast Design System in React with Tailwind CSS & shadcn/ui (DEV.to)](https://dev.to/mahindev/build-a-lightning-fast-design-system-in-react-with-tailwind-css-shadcnui-2a8m)
- [shadcn/ui — documentação oficial](https://ui.shadcn.com)
- [Tailwind CSS — documentação oficial](https://tailwindcss.com/docs)

---

## Ordem de leitura recomendada

Se quiser aprender do zero ao avançado, siga esta ordem:

1. [LWC vs React (DEV.to)](https://dev.to/nickwarren47/lwc-lightning-web-components-vs-react-components-31d1) — entenda a diferença conceitual
2. [Tailwind CSS no LWC — Medium](https://medium.com/@zahisaadieh/how-to-use-tailwind-css-in-salesforce-lightning-web-components-lwc-the-easy-way-10fc199a421d) — base prática da integração CSS
3. [Blog Oficial Salesforce Multi-Framework](https://developer.salesforce.com/blogs/2026/04/build-with-react-run-on-salesforce-introducing-salesforce-multi-framework) — anúncio oficial, leitura obrigatória
4. [salesforcemonday.com — React First-Class Citizen](https://salesforcemonday.com/2026/05/04/salesforce-multi-framework-react-native-platform/) — análise independente com detalhes técnicos
5. [awsquality.com — TDX 2026 Recap](https://www.awsquality.com/salesforce-goes-multi-framework-and-react-is-just-the-beginning/) — roadmap e futuro da plataforma
6. [Microfrontends com React no Salesforce (Medium)](https://medium.com/@lucaskeller/microfrontends-with-react-inside-salesforce-lessons-from-a-real-project-feff9ec04aa2) — caso real em produção
7. [shadcn/ui docs](https://ui.shadcn.com) + [Tailwind CSS docs](https://tailwindcss.com/docs) — referência das bibliotecas

---

*Documento gerado em maio de 2026. O Salesforce Multi-Framework está em Open Beta — verificar status atualizado antes de iniciar implementação.*
