import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router';
import { fetchOrders, getOrder, type Order, type OrderItem } from '@/api/ordersApi';
import {
  PieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
} from 'recharts';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Skeleton } from '@/components/ui/skeleton';
import { ArrowLeft, Package, Truck, Percent, Receipt } from 'lucide-react';

const STATUS_STYLES: Record<string, string> = {
  Draft: 'bg-gray-100 text-gray-700',
  Approved: 'bg-blue-100 text-blue-700',
  Activated: 'bg-green-100 text-green-700',
  Integrated: 'bg-emerald-100 text-emerald-700',
  IntegrationError: 'bg-red-100 text-red-700',
};

const PIE_COLORS = ['#3b82f6', '#10b981', '#f59e0b', '#6366f1'];

function fmt(v: number | null | undefined) {
  if (v == null) return '—';
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(v);
}

function fmtPct(v: number | null | undefined) {
  if (v == null) return '—';
  return `${v.toFixed(2)}%`;
}

function fmtDate(iso: string) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('pt-BR');
}

function buildPieData(items: OrderItem[]) {
  let baseCost = 0;
  let freight = 0;
  let marginValue = 0;
  let taxValue = 0;

  for (const item of items) {
    const cost = (item.ProductionCost__c ?? 0) * item.Quantity;
    const frt = (item.FreightCost__c ?? 0) * item.Quantity;
    const margin = ((item.MarginPercentage__c ?? 0) / 100) * item.UnitPrice * item.Quantity;
    const tax = ((item.TaxPercentage__c ?? 0) / 100) * item.UnitPrice * item.Quantity;
    baseCost += cost;
    freight += frt;
    marginValue += margin;
    taxValue += tax;
  }

  return [
    { name: 'Custo Base', value: Math.round(baseCost) },
    { name: 'Frete', value: Math.round(freight) },
    { name: 'Margem', value: Math.round(marginValue) },
    { name: 'Imposto', value: Math.round(taxValue) },
  ].filter(d => d.value > 0);
}

function buildBarData(items: OrderItem[]) {
  return items.map(item => ({
    name: item.Product2?.Name ?? 'Produto',
    Frete: item.FreightCost__c ?? 0,
    Margem: ((item.MarginPercentage__c ?? 0) / 100) * item.UnitPrice,
    Imposto: ((item.TaxPercentage__c ?? 0) / 100) * item.UnitPrice,
  }));
}

export default function OrderDetail() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [order, setOrder] = useState<Order | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchOrders().then(data => {
      const found = getOrder(data, id ?? '');
      setOrder(found ?? null);
      setLoading(false);
    });
  }, [id]);

  if (loading) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-4">
        <Skeleton className="h-8 w-48" />
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
          {Array.from({ length: 4 }).map((_, i) => (
            <Skeleton key={i} className="h-24" />
          ))}
        </div>
        <Skeleton className="h-64" />
      </div>
    );
  }

  if (!order) {
    return (
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <p className="text-muted-foreground">Pedido não encontrado.</p>
        <Button variant="outline" className="mt-4" onClick={() => navigate('/orders')}>
          Voltar
        </Button>
      </div>
    );
  }

  const items = order.OrderItems.records;
  const totalFreight = items.reduce((s, i) => s + (i.FreightCost__c ?? 0) * i.Quantity, 0);
  const avgMargin =
    items.length > 0
      ? items.reduce((s, i) => s + (i.MarginPercentage__c ?? 0), 0) / items.length
      : 0;
  const avgTax =
    items.length > 0
      ? items.reduce((s, i) => s + (i.TaxPercentage__c ?? 0), 0) / items.length
      : 0;

  const pieData = buildPieData(items);
  const barData = buildBarData(items);

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
      {/* Header */}
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" onClick={() => navigate('/orders')}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div>
          <div className="flex items-center gap-3">
            <h1 className="text-2xl font-bold">{order.OrderNumber}</h1>
            <Badge
              className={`text-xs font-medium ${STATUS_STYLES[order.Status] ?? 'bg-gray-100 text-gray-700'}`}
              variant="outline"
            >
              {order.Status}
            </Badge>
          </div>
          <p className="text-sm text-muted-foreground">
            {order.Account?.Name} · {fmtDate(order.EffectiveDate)}
          </p>
        </div>
      </div>

      {/* KPI cards */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-medium text-muted-foreground">
              Total do Pedido
            </CardTitle>
            <Package className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <p className="text-xl font-bold">{fmt(order.TotalAmount)}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-medium text-muted-foreground">
              Frete Total
            </CardTitle>
            <Truck className="h-4 w-4 text-blue-500" />
          </CardHeader>
          <CardContent>
            <p className="text-xl font-bold text-blue-600">{fmt(totalFreight)}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-medium text-muted-foreground">
              Margem Média
            </CardTitle>
            <Percent className="h-4 w-4 text-emerald-500" />
          </CardHeader>
          <CardContent>
            <p className="text-xl font-bold text-emerald-600">{fmtPct(avgMargin)}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-xs font-medium text-muted-foreground">
              Imposto Médio
            </CardTitle>
            <Receipt className="h-4 w-4 text-amber-500" />
          </CardHeader>
          <CardContent>
            <p className="text-xl font-bold text-amber-600">{fmtPct(avgTax)}</p>
          </CardContent>
        </Card>
      </div>

      {/* Charts */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-semibold">Composição do Preço</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <PieChart>
                <Pie
                  data={pieData}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {pieData.map((_, index) => (
                    <Cell key={index} fill={PIE_COLORS[index % PIE_COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  formatter={(value) =>
                    new Intl.NumberFormat('pt-BR', {
                      style: 'currency',
                      currency: 'BRL',
                    }).format(Number(value))
                  }
                />
                <Legend />
              </PieChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-sm font-semibold">
              Frete · Margem · Imposto por Produto
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={280}>
              <BarChart data={barData} margin={{ top: 4, right: 8, left: 0, bottom: 40 }}>
                <CartesianGrid strokeDasharray="3 3" className="stroke-border" />
                <XAxis
                  dataKey="name"
                  tick={{ fontSize: 11 }}
                  angle={-20}
                  textAnchor="end"
                  interval={0}
                />
                <YAxis tick={{ fontSize: 11 }} />
                <Tooltip
                  formatter={(value) =>
                    new Intl.NumberFormat('pt-BR', {
                      style: 'currency',
                      currency: 'BRL',
                    }).format(Number(value))
                  }
                />
                <Legend />
                <Bar dataKey="Frete" fill="#3b82f6" radius={[4, 4, 0, 0]} />
                <Bar dataKey="Margem" fill="#10b981" radius={[4, 4, 0, 0]} />
                <Bar dataKey="Imposto" fill="#f59e0b" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>

      {/* Items table */}
      <Card>
        <CardHeader>
          <CardTitle className="text-sm font-semibold">Itens do Pedido</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Produto</TableHead>
                <TableHead className="text-right">Qtd</TableHead>
                <TableHead className="text-right">Preço Unit.</TableHead>
                <TableHead className="text-right">Custo Prod.</TableHead>
                <TableHead className="text-right">Frete</TableHead>
                <TableHead className="text-right">Margem</TableHead>
                <TableHead className="text-right">Imposto</TableHead>
                <TableHead className="text-right">Total</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {items.map(item => (
                <TableRow key={item.Id}>
                  <TableCell>
                    <div>
                      <p className="font-medium text-sm">{item.Product2?.Name ?? '—'}</p>
                      <p className="text-xs text-muted-foreground">
                        {item.Product2?.ProductCode ?? ''}
                      </p>
                    </div>
                  </TableCell>
                  <TableCell className="text-right">{item.Quantity}</TableCell>
                  <TableCell className="text-right">{fmt(item.UnitPrice)}</TableCell>
                  <TableCell className="text-right">{fmt(item.ProductionCost__c)}</TableCell>
                  <TableCell className="text-right text-blue-600">
                    {fmt(item.FreightCost__c)}
                  </TableCell>
                  <TableCell className="text-right text-emerald-600">
                    {fmtPct(item.MarginPercentage__c)}
                  </TableCell>
                  <TableCell className="text-right text-amber-600">
                    {fmtPct(item.TaxPercentage__c)}
                  </TableCell>
                  <TableCell className="text-right font-semibold">
                    {fmt(item.TotalPrice)}
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
