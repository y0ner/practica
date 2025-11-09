import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { AuthGuard } from './guards/authguard';

// Client components with aliases
import { Getall as ClientGetall } from './components/Clientes/getall/getall';
import { Create as ClientCreate } from './components/Clientes/create/create';
import { Update as ClientUpdate } from './components/Clientes/update/update';
import { Delete as ClientDelete } from './components/Clientes/delete/delete';
// Sale components with aliases
import { Getall as SaleGetall } from './components/Ventas/getall/getall';
import { Create as SaleCreate } from './components/Ventas/create/create';
import { Update as SaleUpdate } from './components/Ventas/update/update';
import { Delete as SaleDelete } from './components/Ventas/delete/delete';

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
        path: "Clientes",
        component: ClientGetall,
        canActivate: [AuthGuard]
    },
    {
        path: "Clientes/new",
        component: ClientCreate,
        canActivate: [AuthGuard]
    },
    {
        path: "Clientes/edit/:id",
        component: ClientUpdate,
        canActivate: [AuthGuard]
    },
    {
        path: "Clientes/delete/:id",
        component: ClientDelete,
        canActivate: [AuthGuard]
    },    {
        path: "Ventas",
        component: SaleGetall,
        canActivate: [AuthGuard]
    },
    {
        path: "Ventas/new",
        component: SaleCreate,
        canActivate: [AuthGuard]
    },
    {
        path: "Ventas/edit/:id",
        component: SaleUpdate,
        canActivate: [AuthGuard]
    },
    {
        path: "Ventas/delete/:id",
        component: SaleDelete,
        canActivate: [AuthGuard]
    },
    {
        path: "**",
        redirectTo: "/login",
        pathMatch: "full"
    }
];
