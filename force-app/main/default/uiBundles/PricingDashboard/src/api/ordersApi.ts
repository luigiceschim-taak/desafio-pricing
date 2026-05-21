import { executeGraphQL } from './graphqlClient';
import type { GetOrdersQuery } from './graphql-operations-types';

export interface OrderItem {
  Id: string;
  Product2: { Name: string; ProductCode: string } | null;
  UnitPrice: number;
  Quantity: number;
  TotalPrice: number;
  FreightCost__c: number | null;
  MarginPercentage__c: number | null;
  TaxPercentage__c: number | null;
  ProductionCost__c: number | null;
  TotalSellingPrice__c: number | null;
  IdealPrice__c: number | null;
}

export interface Order {
  Id: string;
  OrderNumber: string;
  Status: string;
  EffectiveDate: string;
  TotalAmount: number;
  Account: { Name: string } | null;
  OrderItems: { records: OrderItem[] };
}

// ---------- mock data (used when SDK is unavailable locally) ----------

const MOCK_ORDERS: Order[] = [
  {
    Id: '001A000000001',
    OrderNumber: 'ORD-0001',
    Status: 'Approved',
    EffectiveDate: '2026-01-15',
    TotalAmount: 48500,
    Account: { Name: 'Acme Corp' },
    OrderItems: {
      records: [
        {
          Id: 'OI001',
          Product2: { Name: 'Produto Alpha', ProductCode: 'ALPHA-001' },
          UnitPrice: 1200,
          Quantity: 10,
          TotalPrice: 12000,
          FreightCost__c: 240,
          MarginPercentage__c: 18.5,
          TaxPercentage__c: 12,
          ProductionCost__c: 800,
          TotalSellingPrice__c: 14400,
          IdealPrice__c: 1300,
        },
        {
          Id: 'OI002',
          Product2: { Name: 'Produto Beta', ProductCode: 'BETA-002' },
          UnitPrice: 3650,
          Quantity: 10,
          TotalPrice: 36500,
          FreightCost__c: 730,
          MarginPercentage__c: 22,
          TaxPercentage__c: 10,
          ProductionCost__c: 2200,
          TotalSellingPrice__c: 40150,
          IdealPrice__c: 3900,
        },
      ],
    },
  },
  {
    Id: '001A000000002',
    OrderNumber: 'ORD-0002',
    Status: 'Draft',
    EffectiveDate: '2026-02-10',
    TotalAmount: 27300,
    Account: { Name: 'Globex Industries' },
    OrderItems: {
      records: [
        {
          Id: 'OI003',
          Product2: { Name: 'Produto Gamma', ProductCode: 'GAMMA-003' },
          UnitPrice: 910,
          Quantity: 30,
          TotalPrice: 27300,
          FreightCost__c: 546,
          MarginPercentage__c: 15,
          TaxPercentage__c: 8,
          ProductionCost__c: 650,
          TotalSellingPrice__c: 29120,
          IdealPrice__c: 1000,
        },
      ],
    },
  },
  {
    Id: '001A000000003',
    OrderNumber: 'ORD-0003',
    Status: 'Integrated',
    EffectiveDate: '2026-03-05',
    TotalAmount: 91200,
    Account: { Name: 'Initech Solutions' },
    OrderItems: {
      records: [
        {
          Id: 'OI004',
          Product2: { Name: 'Produto Delta', ProductCode: 'DELTA-004' },
          UnitPrice: 4560,
          Quantity: 20,
          TotalPrice: 91200,
          FreightCost__c: 1824,
          MarginPercentage__c: 25,
          TaxPercentage__c: 14,
          ProductionCost__c: 3000,
          TotalSellingPrice__c: 102144,
          IdealPrice__c: 5000,
        },
      ],
    },
  },
  {
    Id: '001A000000004',
    OrderNumber: 'ORD-0004',
    Status: 'IntegrationError',
    EffectiveDate: '2026-03-20',
    TotalAmount: 15600,
    Account: { Name: 'Umbrella Corp' },
    OrderItems: {
      records: [
        {
          Id: 'OI005',
          Product2: { Name: 'Produto Epsilon', ProductCode: 'EPS-005' },
          UnitPrice: 780,
          Quantity: 20,
          TotalPrice: 15600,
          FreightCost__c: 312,
          MarginPercentage__c: 10,
          TaxPercentage__c: 9,
          ProductionCost__c: 600,
          TotalSellingPrice__c: 16380,
          IdealPrice__c: 850,
        },
      ],
    },
  },
];

// ---------- GraphQL ----------

const ORDERS_QUERY = /* GraphQL */ `
  query GetOrders {
    uiapi {
      query {
        Order(orderBy: { EffectiveDate: { order: DESC } }, first: 50) {
          edges {
            node {
              Id
              OrderNumber { value }
              Status { value }
              EffectiveDate { value }
              TotalAmount { value }
              Account { Name { value } }
              OrderItems {
                edges {
                  node {
                    Id
                    UnitPrice { value }
                    Quantity { value }
                    TotalPrice { value }
                    FreightCost__c { value }
                    MarginPercentage__c { value }
                    TaxPercentage__c { value }
                    ProductionCost__c { value }
                    TotalSellingPrice__c { value }
                    IdealPrice__c { value }
                    Product2 {
                      Name { value }
                      ProductCode { value }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
`;

function flattenGraphQLOrders(raw: GetOrdersQuery): Order[] {
  const edges = raw?.uiapi?.query?.Order?.edges ?? [];
  return (edges.filter(Boolean) as NonNullable<typeof edges[number]>[]).map(e => {
    const n = e.node!;
    return {
      Id: n.Id,
      OrderNumber: n.OrderNumber?.value ?? '',
      Status: n.Status?.value ?? '',
      EffectiveDate: n.EffectiveDate?.value ?? '',
      TotalAmount: n.TotalAmount?.value ?? 0,
      Account: n.Account ? { Name: n.Account.Name?.value ?? '' } : null,
      OrderItems: {
        records: (n.OrderItems?.edges ?? [])
          .filter(Boolean)
          .map(ie => {
            const item = ie!.node!;
            return {
              Id: item.Id,
              Product2: item.Product2
                ? {
                    Name: item.Product2.Name?.value ?? '',
                    ProductCode: item.Product2.ProductCode?.value ?? '',
                  }
                : null,
              UnitPrice: item.UnitPrice?.value ?? 0,
              Quantity: item.Quantity?.value ?? 0,
              TotalPrice: item.TotalPrice?.value ?? 0,
              FreightCost__c: item.FreightCost__c?.value ?? null,
              MarginPercentage__c: item.MarginPercentage__c?.value ?? null,
              TaxPercentage__c: item.TaxPercentage__c?.value ?? null,
              ProductionCost__c: item.ProductionCost__c?.value ?? null,
              TotalSellingPrice__c: item.TotalSellingPrice__c?.value ?? null,
              IdealPrice__c: item.IdealPrice__c?.value ?? null,
            };
          }),
      },
    };
  });
}

export async function fetchOrders(): Promise<Order[]> {
  try {
    const data = await executeGraphQL<GetOrdersQuery>(ORDERS_QUERY);
    const orders = flattenGraphQLOrders(data);
    return orders.length > 0 ? orders : MOCK_ORDERS;
  } catch {
    return MOCK_ORDERS;
  }
}

export function getOrder(orders: Order[], id: string): Order | undefined {
  return orders.find(o => o.Id === id);
}
