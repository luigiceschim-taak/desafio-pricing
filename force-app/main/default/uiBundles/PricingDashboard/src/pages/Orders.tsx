import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router';
import { fetchOrders, type Order } from '@/api/ordersApi';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { Search, ShoppingCart, TrendingUp, AlertCircle, CheckCircle2 } from 'lucide-react';

const STATUS_STYLES: Record<string, string> = {
  Draft: 'bg-gray-100 text-gray-700',
  Approved: 'bg-blue-100 text-blue-700',
  Activated: 'bg-green-100 text-green-700',
  Integrated: 'bg-emerald-100 text-emerald-700',
  IntegrationError: 'bg-red-100 text-red-700',
};

function fmt(value: number) {
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value);
}

function fmtDate(iso: string) {
  if (!iso) return '—';
  return new Date(iso).toLocaleDateString('pt-BR');
}

export default function Orders() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const navigate = useNavigate();

  useEffect(() => {
    fetchOrders().then(data => {
      setOrders(data);
      setLoading(false);
    });
  }, []);

  const filtered = orders.filter(o => {
    const q = search.toLowerCase();
    return (
      o.OrderNumber.toLowerCase().includes(q) ||
      (o.Account?.Name ?? '').toLowerCase().includes(q) ||
      o.Status.toLowerCase().includes(q)
    );
  });

  const totalRevenue = orders.reduce((sum, o) => sum + o.TotalAmount, 0);
  const approved = orders.filter(o => o.Status === 'Approved').length;
  const errors = orders.filter(o => o.Status === 'IntegrationError').length;

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-foreground">Pedidos</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Visão geral dos pedidos e pricing calculado
        </p>
      </div>

      {/* KPI cards */}
      <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Total de Pedidos
            </CardTitle>
            <ShoppingCart className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? '—' : orders.length}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Receita Total
            </CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">{loading ? '—' : fmt(totalRevenue)}</p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-sm font-medium text-muted-foreground">
              Aprovados / Erros
            </CardTitle>
            {errors > 0 ? (
              <AlertCircle className="h-4 w-4 text-red-500" />
            ) : (
              <CheckCircle2 className="h-4 w-4 text-emerald-500" />
            )}
          </CardHeader>
          <CardContent>
            <p className="text-2xl font-bold">
              {loading ? '—' : `${approved} / ${errors}`}
            </p>
          </CardContent>
        </Card>
      </div>

      {/* Table */}
      <Card>
        <CardHeader>
          <div className="flex items-center gap-3">
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="Buscar por número, conta ou status..."
                value={search}
                onChange={e => setSearch(e.target.value)}
                className="pl-9"
              />
            </div>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Número</TableHead>
                <TableHead>Conta</TableHead>
                <TableHead>Data</TableHead>
                <TableHead>Status</TableHead>
                <TableHead>Itens</TableHead>
                <TableHead className="text-right">Total</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {loading
                ? Array.from({ length: 4 }).map((_, i) => (
                    <TableRow key={i}>
                      {Array.from({ length: 6 }).map((_, j) => (
                        <TableCell key={j}>
                          <Skeleton className="h-4 w-full" />
                        </TableCell>
                      ))}
                    </TableRow>
                  ))
                : filtered.map(order => (
                    <TableRow
                      key={order.Id}
                      className="cursor-pointer hover:bg-muted/50"
                      onClick={() => navigate(`/orders/${order.Id}`)}
                    >
                      <TableCell className="font-medium">{order.OrderNumber}</TableCell>
                      <TableCell>{order.Account?.Name ?? '—'}</TableCell>
                      <TableCell>{fmtDate(order.EffectiveDate)}</TableCell>
                      <TableCell>
                        <Badge
                          className={`text-xs font-medium ${STATUS_STYLES[order.Status] ?? 'bg-gray-100 text-gray-700'}`}
                          variant="outline"
                        >
                          {order.Status}
                        </Badge>
                      </TableCell>
                      <TableCell>{order.OrderItems.records.length}</TableCell>
                      <TableCell className="text-right font-medium">
                        {fmt(order.TotalAmount)}
                      </TableCell>
                    </TableRow>
                  ))}
              {!loading && filtered.length === 0 && (
                <TableRow>
                  <TableCell colSpan={6} className="text-center py-8 text-muted-foreground">
                    Nenhum pedido encontrado.
                  </TableCell>
                </TableRow>
              )}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
