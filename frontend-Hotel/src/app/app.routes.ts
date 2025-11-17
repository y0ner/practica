import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { authGuard } from './guards/authguard';

// CRUD imports
import { Getall as HotelGetall } from './components/Hotel/getall/getall';
import { Create as HotelCreate } from './components/Hotel/create/create';
import { Update as HotelUpdate } from './components/Hotel/update/update';
import { Delete as HotelDelete } from './components/Hotel/delete/delete'; 
import { Getall as TipoHabitacionGetall } from './components/TipoHabitacion/getall/getall';
import { Create as TipoHabitacionCreate } from './components/TipoHabitacion/create/create';
import { Update as TipoHabitacionUpdate } from './components/TipoHabitacion/update/update';
import { Delete as TipoHabitacionDelete } from './components/TipoHabitacion/delete/delete'; 
import { Getall as HabitacionGetall } from './components/Habitacion/getall/getall';
import { Create as HabitacionCreate } from './components/Habitacion/create/create';
import { Update as HabitacionUpdate } from './components/Habitacion/update/update';
import { Delete as HabitacionDelete } from './components/Habitacion/delete/delete'; 
import { Getall as TemporadaGetall } from './components/Temporada/getall/getall';
import { Create as TemporadaCreate } from './components/Temporada/create/create';
import { Update as TemporadaUpdate } from './components/Temporada/update/update';
import { Delete as TemporadaDelete } from './components/Temporada/delete/delete'; 
import { Getall as TarifaGetall } from './components/Tarifa/getall/getall';
import { Create as TarifaCreate } from './components/Tarifa/create/create';
import { Update as TarifaUpdate } from './components/Tarifa/update/update';
import { Delete as TarifaDelete } from './components/Tarifa/delete/delete'; 
import { Getall as ClienteGetall } from './components/Cliente/getall/getall';
import { Create as ClienteCreate } from './components/Cliente/create/create';
import { Update as ClienteUpdate } from './components/Cliente/update/update';
import { Delete as ClienteDelete } from './components/Cliente/delete/delete'; 
import { Getall as ServicioGetall } from './components/Servicio/getall/getall';
import { Create as ServicioCreate } from './components/Servicio/create/create';
import { Update as ServicioUpdate } from './components/Servicio/update/update';
import { Delete as ServicioDelete } from './components/Servicio/delete/delete';
 import { Getall as ReservaGetall } from './components/Reserva/getall/getall';
import { Create as ReservaCreate } from './components/Reserva/create/create';
import { Update as ReservaUpdate } from './components/Reserva/update/update';
import { Delete as ReservaDelete } from './components/Reserva/delete/delete'; 
import { Getall as PagoGetall } from './components/Pago/getall/getall';
import { Create as PagoCreate } from './components/Pago/create/create';
import { Update as PagoUpdate } from './components/Pago/update/update';
import { Delete as PagoDelete } from './components/Pago/delete/delete';

export const routes: Routes = [
    { path: 'login', component: Login },
    { path: 'register', component: Register },
    { path: '', redirectTo: '/Hotel', pathMatch: 'full' },

    // CRUD routes
    { path: 'Hotel', component: HotelGetall, canActivate: [authGuard] },
    { path: 'Hotel/new', component: HotelCreate, canActivate: [authGuard] },
    { path: 'Hotel/edit/:id', component: HotelUpdate, canActivate: [authGuard] },
    { path: 'Hotel/delete/:id', component: HotelDelete, canActivate: [authGuard] }, 
    { path: 'TipoHabitacion', component: TipoHabitacionGetall, canActivate: [authGuard] },
    { path: 'TipoHabitacion/new', component: TipoHabitacionCreate, canActivate: [authGuard] },
    { path: 'TipoHabitacion/edit/:id', component: TipoHabitacionUpdate, canActivate: [authGuard] },
    { path: 'TipoHabitacion/delete/:id', component: TipoHabitacionDelete, canActivate: [authGuard] },
    { path: 'Habitacion', component: HabitacionGetall, canActivate: [authGuard] },
    { path: 'Habitacion/new', component: HabitacionCreate, canActivate: [authGuard] },
    { path: 'Habitacion/edit/:id', component: HabitacionUpdate, canActivate: [authGuard] },
    { path: 'Habitacion/delete/:id', component: HabitacionDelete, canActivate: [authGuard] }, 
    { path: 'Temporada', component: TemporadaGetall, canActivate: [authGuard] },
    { path: 'Temporada/new', component: TemporadaCreate, canActivate: [authGuard] },
    { path: 'Temporada/edit/:id', component: TemporadaUpdate, canActivate: [authGuard] },
    { path: 'Temporada/delete/:id', component: TemporadaDelete, canActivate: [authGuard] }, 
    { path: 'Tarifa', component: TarifaGetall, canActivate: [authGuard] },
    { path: 'Tarifa/new', component: TarifaCreate, canActivate: [authGuard] },
    { path: 'Tarifa/edit/:id', component: TarifaUpdate, canActivate: [authGuard] },
    { path: 'Tarifa/delete/:id', component: TarifaDelete, canActivate: [authGuard] }, 
    { path: 'Cliente', component: ClienteGetall, canActivate: [authGuard] },
    { path: 'Cliente/new', component: ClienteCreate, canActivate: [authGuard] },
    { path: 'Cliente/edit/:id', component: ClienteUpdate, canActivate: [authGuard] },
    { path: 'Cliente/delete/:id', component: ClienteDelete, canActivate: [authGuard] }, 
    { path: 'Servicio', component: ServicioGetall, canActivate: [authGuard] },
    { path: 'Servicio/new', component: ServicioCreate, canActivate: [authGuard] },
    { path: 'Servicio/edit/:id', component: ServicioUpdate, canActivate: [authGuard] },
    { path: 'Servicio/delete/:id', component: ServicioDelete, canActivate: [authGuard] }, 
    { path: 'Reserva', component: ReservaGetall, canActivate: [authGuard] },
    { path: 'Reserva/new', component: ReservaCreate, canActivate: [authGuard] },
    { path: 'Reserva/edit/:id', component: ReservaUpdate, canActivate: [authGuard] },
    { path: 'Reserva/delete/:id', component: ReservaDelete, canActivate: [authGuard] },
    { path: 'Pago', component: PagoGetall, canActivate: [authGuard] },
    { path: 'Pago/new', component: PagoCreate, canActivate: [authGuard] },
    { path: 'Pago/edit/:id', component: PagoUpdate, canActivate: [authGuard] },
    { path: 'Pago/delete/:id', component: PagoDelete, canActivate: [authGuard] },

    { path: '**', redirectTo: '/login' }
];
