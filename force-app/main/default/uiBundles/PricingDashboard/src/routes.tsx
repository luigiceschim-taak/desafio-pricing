import type { RouteObject } from 'react-router';
import AppLayout from '@/appLayout';
import Home from './pages/Home';
import Orders from './pages/Orders';
import OrderDetail from './pages/OrderDetail';
import NotFound from './pages/NotFound';

export const routes: RouteObject[] = [
  {
    path: '/',
    element: <AppLayout />,
    children: [
      {
        index: true,
        element: <Home />,
        handle: { showInNavigation: true, label: 'Home' },
      },
      {
        path: 'orders',
        element: <Orders />,
        handle: { showInNavigation: true, label: 'Pedidos' },
      },
      {
        path: 'orders/:id',
        element: <OrderDetail />,
      },
      {
        path: '*',
        element: <NotFound />,
      },
    ],
  },
];
