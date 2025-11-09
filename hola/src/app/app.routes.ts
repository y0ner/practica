import { Routes } from '@angular/router';

import { Getall as Cambio1Getall } from './components/cambio1/getall/getall';
import { Create as Cambio1Create } from './components/cambio1/create/create';
import { Update as Cambio1Update } from './components/cambio1/update/update';
import { Delete as Cambio1Delete } from './components/cambio1/delete/delete';import { Getall as Cambio2Getall } from './components/cambio2/getall/getall';
import { Create as Cambio2Create } from './components/cambio2/create/create';
import { Update as Cambio2Update } from './components/cambio2/update/update';
import { Delete as Cambio2Delete } from './components/cambio2/delete/delete';import { Getall as Cambio3Getall } from './components/cambio3/getall/getall';
import { Create as Cambio3Create } from './components/cambio3/create/create';
import { Update as Cambio3Update } from './components/cambio3/update/update';
import { Delete as Cambio3Delete } from './components/cambio3/delete/delete';

export const routes: Routes = [
    { path: '', redirectTo: '/', pathMatch: 'full' },
    { path: "cambio1", component: Cambio1Getall },
    { path: "cambio1/new", component: Cambio1Create },
    { path: "cambio1/edit/:id", component: Cambio1Update },
    { path: "cambio1/delete/:id", component: Cambio1Delete },    { path: "cambio2", component: Cambio2Getall },
    { path: "cambio2/new", component: Cambio2Create },
    { path: "cambio2/edit/:id", component: Cambio2Update },
    { path: "cambio2/delete/:id", component: Cambio2Delete },    { path: "cambio3", component: Cambio3Getall },
    { path: "cambio3/new", component: Cambio3Create },
    { path: "cambio3/edit/:id", component: Cambio3Update },
    { path: "cambio3/delete/:id", component: Cambio3Delete },
];
