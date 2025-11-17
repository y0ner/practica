import { Routes } from '@angular/router';

import { Getall as HotelesGetall } from './components/Hoteles/getall/getall';
import { Create as HotelesCreate } from './components/Hoteles/create/create';
import { Update as HotelesUpdate } from './components/Hoteles/update/update';
import { Delete as HotelesDelete } from './components/Hoteles/delete/delete';import { Getall as HabitacionesGetall } from './components/Habitaciones/getall/getall';
import { Create as HabitacionesCreate } from './components/Habitaciones/create/create';
import { Update as HabitacionesUpdate } from './components/Habitaciones/update/update';
import { Delete as HabitacionesDelete } from './components/Habitaciones/delete/delete';import { Getall as Tipos de habitaciónGetall } from './components/Tipos de habitación/getall/getall';
import { Create as Tipos de habitaciónCreate } from './components/Tipos de habitación/create/create';
import { Update as Tipos de habitaciónUpdate } from './components/Tipos de habitación/update/update';
import { Delete as Tipos de habitaciónDelete } from './components/Tipos de habitación/delete/delete';import { Getall as TemporadasGetall } from './components/Temporadas/getall/getall';
import { Create as TemporadasCreate } from './components/Temporadas/create/create';
import { Update as TemporadasUpdate } from './components/Temporadas/update/update';
import { Delete as TemporadasDelete } from './components/Temporadas/delete/delete';import { Getall as TarifasGetall } from './components/Tarifas/getall/getall';
import { Create as TarifasCreate } from './components/Tarifas/create/create';
import { Update as TarifasUpdate } from './components/Tarifas/update/update';
import { Delete as TarifasDelete } from './components/Tarifas/delete/delete';import { Getall as ClientesGetall } from './components/Clientes/getall/getall';
import { Create as ClientesCreate } from './components/Clientes/create/create';
import { Update as ClientesUpdate } from './components/Clientes/update/update';
import { Delete as ClientesDelete } from './components/Clientes/delete/delete';import { Getall as ReservasGetall } from './components/Reservas/getall/getall';
import { Create as ReservasCreate } from './components/Reservas/create/create';
import { Update as ReservasUpdate } from './components/Reservas/update/update';
import { Delete as ReservasDelete } from './components/Reservas/delete/delete';import { Getall as ServiciosGetall } from './components/Servicios/getall/getall';
import { Create as ServiciosCreate } from './components/Servicios/create/create';
import { Update as ServiciosUpdate } from './components/Servicios/update/update';
import { Delete as ServiciosDelete } from './components/Servicios/delete/delete';import { Getall as PagosGetall } from './components/Pagos/getall/getall';
import { Create as PagosCreate } from './components/Pagos/create/create';
import { Update as PagosUpdate } from './components/Pagos/update/update';
import { Delete as PagosDelete } from './components/Pagos/delete/delete';

export const routes: Routes = [
    { path: '', redirectTo: '/', pathMatch: 'full' },
    { path: "Hoteles", component: HotelesGetall },
    { path: "Hoteles/new", component: HotelesCreate },
    { path: "Hoteles/edit/:id", component: HotelesUpdate },
    { path: "Hoteles/delete/:id", component: HotelesDelete },    { path: "Habitaciones", component: HabitacionesGetall },
    { path: "Habitaciones/new", component: HabitacionesCreate },
    { path: "Habitaciones/edit/:id", component: HabitacionesUpdate },
    { path: "Habitaciones/delete/:id", component: HabitacionesDelete },    { path: "Tipos de habitación", component: Tipos de habitaciónGetall },
    { path: "Tipos de habitación/new", component: Tipos de habitaciónCreate },
    { path: "Tipos de habitación/edit/:id", component: Tipos de habitaciónUpdate },
    { path: "Tipos de habitación/delete/:id", component: Tipos de habitaciónDelete },    { path: "Temporadas", component: TemporadasGetall },
    { path: "Temporadas/new", component: TemporadasCreate },
    { path: "Temporadas/edit/:id", component: TemporadasUpdate },
    { path: "Temporadas/delete/:id", component: TemporadasDelete },    { path: "Tarifas", component: TarifasGetall },
    { path: "Tarifas/new", component: TarifasCreate },
    { path: "Tarifas/edit/:id", component: TarifasUpdate },
    { path: "Tarifas/delete/:id", component: TarifasDelete },    { path: "Clientes", component: ClientesGetall },
    { path: "Clientes/new", component: ClientesCreate },
    { path: "Clientes/edit/:id", component: ClientesUpdate },
    { path: "Clientes/delete/:id", component: ClientesDelete },    { path: "Reservas", component: ReservasGetall },
    { path: "Reservas/new", component: ReservasCreate },
    { path: "Reservas/edit/:id", component: ReservasUpdate },
    { path: "Reservas/delete/:id", component: ReservasDelete },    { path: "Servicios", component: ServiciosGetall },
    { path: "Servicios/new", component: ServiciosCreate },
    { path: "Servicios/edit/:id", component: ServiciosUpdate },
    { path: "Servicios/delete/:id", component: ServiciosDelete },    { path: "Pagos", component: PagosGetall },
    { path: "Pagos/new", component: PagosCreate },
    { path: "Pagos/edit/:id", component: PagosUpdate },
    { path: "Pagos/delete/:id", component: PagosDelete },
];
