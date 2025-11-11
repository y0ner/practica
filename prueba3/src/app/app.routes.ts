import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { authGuard } from './guards/authguard';

// Client components with aliases
import { Getall as ClientGetall } from './components/clientes/getall/getall';
import { Create as ClientCreate } from './components/clientes/create/create';
import { Update as ClientUpdate } from './components/clientes/update/update';
import { Delete as ClientDelete } from './components/clientes/delete/delete';
// Sale components with aliases
import { Getall as SaleGetall } from './components/ventas/getall/getall';
import { Create as SaleCreate } from './components/ventas/create/create';
import { Update as SaleUpdate } from './components/ventas/update/update';
import { Delete as SaleDelete } from './components/ventas/delete/delete';

export const routes: Routes = [
    { 
        path: '', 
        redirectTo: '/login', 
        pathMatch: 'full' 
    },
    {
        path: "login",
        component: Login
    },
    {
        path: "register",
        component: Register
    },
    {
        path: "clientes",
        component: ClientGetall,
        canActivate: [authGuard]
    },
    {
        path: "clientes/new",
        component: ClientCreate,
        canActivate: [authGuard]
    },
    {
        path: "clientes/edit/:id",
        component: ClientUpdate,
        canActivate: [authGuard]
    },
    {
        path: "clientes/delete/:id",
        component: ClientDelete,
        canActivate: [authGuard]
    },    {
        path: "ventas",
        component: SaleGetall,
        canActivate: [authGuard]
    },
    {
        path: "ventas/new",
        component: SaleCreate,
        canActivate: [authGuard]
    },
    {
        path: "ventas/edit/:id",
        component: SaleUpdate,
        canActivate: [authGuard]
    },
    {
        path: "ventas/delete/:id",
        component: SaleDelete,
        canActivate: [authGuard]
    },
    {
        path: "**",
        redirectTo: "/login",
        pathMatch: "full"
    }
];
