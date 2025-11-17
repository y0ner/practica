import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { authGuard } from './guards/authguard';

// Hotel components with aliases
import { Getall as HotelGetall } from './components/Hotel/getall/getall';
import { Create as HotelCreate } from './components/Hotel/create/create';
import { Update as HotelUpdate } from './components/Hotel/update/update';
import { Delete as HotelDelete } from './components/Hotel/delete/delete';
// RoomType components with aliases
import { Getall as RoomTypeGetall } from './components/TipoHabitacion/getall/getall';
import { Create as RoomTypeCreate } from './components/TipoHabitacion/create/create';
import { Update as RoomTypeUpdate } from './components/TipoHabitacion/update/update';
import { Delete as RoomTypeDelete } from './components/TipoHabitacion/delete/delete';
// Room components with aliases
import { Getall as RoomGetall } from './components/Habitacion/getall/getall';
import { Create as RoomCreate } from './components/Habitacion/create/create';
import { Update as RoomUpdate } from './components/Habitacion/update/update';
import { Delete as RoomDelete } from './components/Habitacion/delete/delete';
// Season components with aliases
import { Getall as SeasonGetall } from './components/Temporada/getall/getall';
import { Create as SeasonCreate } from './components/Temporada/create/create';
import { Update as SeasonUpdate } from './components/Temporada/update/update';
import { Delete as SeasonDelete } from './components/Temporada/delete/delete';
// Rate components with aliases
import { Getall as RateGetall } from './components/Tarifa/getall/getall';
import { Create as RateCreate } from './components/Tarifa/create/create';
import { Update as RateUpdate } from './components/Tarifa/update/update';
import { Delete as RateDelete } from './components/Tarifa/delete/delete';
// Client components with aliases
import { Getall as ClientGetall } from './components/Cliente/getall/getall';
import { Create as ClientCreate } from './components/Cliente/create/create';
import { Update as ClientUpdate } from './components/Cliente/update/update';
import { Delete as ClientDelete } from './components/Cliente/delete/delete';
// Service components with aliases
import { Getall as ServiceGetall } from './components/Servicio/getall/getall';
import { Create as ServiceCreate } from './components/Servicio/create/create';
import { Update as ServiceUpdate } from './components/Servicio/update/update';
import { Delete as ServiceDelete } from './components/Servicio/delete/delete';
// Reservation components with aliases
import { Getall as ReservationGetall } from './components/Reserva/getall/getall';
import { Create as ReservationCreate } from './components/Reserva/create/create';
import { Update as ReservationUpdate } from './components/Reserva/update/update';
import { Delete as ReservationDelete } from './components/Reserva/delete/delete';
// Payment components with aliases
import { Getall as PaymentGetall } from './components/Pago/getall/getall';
import { Create as PaymentCreate } from './components/Pago/create/create';
import { Update as PaymentUpdate } from './components/Pago/update/update';
import { Delete as PaymentDelete } from './components/Pago/delete/delete';

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
        path: "Hotel",
        component: HotelGetall,
        canActivate: [authGuard]
    },
    {
        path: "Hotel/new",
        component: HotelCreate,
        canActivate: [authGuard]
    },
    {
        path: "Hotel/edit/:id",
        component: HotelUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Hotel/delete/:id",
        component: HotelDelete,
        canActivate: [authGuard]
    },    {
        path: "TipoHabitacion",
        component: RoomTypeGetall,
        canActivate: [authGuard]
    },
    {
        path: "TipoHabitacion/new",
        component: RoomTypeCreate,
        canActivate: [authGuard]
    },
    {
        path: "TipoHabitacion/edit/:id",
        component: RoomTypeUpdate,
        canActivate: [authGuard]
    },
    {
        path: "TipoHabitacion/delete/:id",
        component: RoomTypeDelete,
        canActivate: [authGuard]
    },    {
        path: "Habitacion",
        component: RoomGetall,
        canActivate: [authGuard]
    },
    {
        path: "Habitacion/new",
        component: RoomCreate,
        canActivate: [authGuard]
    },
    {
        path: "Habitacion/edit/:id",
        component: RoomUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Habitacion/delete/:id",
        component: RoomDelete,
        canActivate: [authGuard]
    },    {
        path: "Temporada",
        component: SeasonGetall,
        canActivate: [authGuard]
    },
    {
        path: "Temporada/new",
        component: SeasonCreate,
        canActivate: [authGuard]
    },
    {
        path: "Temporada/edit/:id",
        component: SeasonUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Temporada/delete/:id",
        component: SeasonDelete,
        canActivate: [authGuard]
    },    {
        path: "Tarifa",
        component: RateGetall,
        canActivate: [authGuard]
    },
    {
        path: "Tarifa/new",
        component: RateCreate,
        canActivate: [authGuard]
    },
    {
        path: "Tarifa/edit/:id",
        component: RateUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Tarifa/delete/:id",
        component: RateDelete,
        canActivate: [authGuard]
    },    {
        path: "Cliente",
        component: ClientGetall,
        canActivate: [authGuard]
    },
    {
        path: "Cliente/new",
        component: ClientCreate,
        canActivate: [authGuard]
    },
    {
        path: "Cliente/edit/:id",
        component: ClientUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Cliente/delete/:id",
        component: ClientDelete,
        canActivate: [authGuard]
    },    {
        path: "Servicio",
        component: ServiceGetall,
        canActivate: [authGuard]
    },
    {
        path: "Servicio/new",
        component: ServiceCreate,
        canActivate: [authGuard]
    },
    {
        path: "Servicio/edit/:id",
        component: ServiceUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Servicio/delete/:id",
        component: ServiceDelete,
        canActivate: [authGuard]
    },    {
        path: "Reserva",
        component: ReservationGetall,
        canActivate: [authGuard]
    },
    {
        path: "Reserva/new",
        component: ReservationCreate,
        canActivate: [authGuard]
    },
    {
        path: "Reserva/edit/:id",
        component: ReservationUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Reserva/delete/:id",
        component: ReservationDelete,
        canActivate: [authGuard]
    },    {
        path: "Pago",
        component: PaymentGetall,
        canActivate: [authGuard]
    },
    {
        path: "Pago/new",
        component: PaymentCreate,
        canActivate: [authGuard]
    },
    {
        path: "Pago/edit/:id",
        component: PaymentUpdate,
        canActivate: [authGuard]
    },
    {
        path: "Pago/delete/:id",
        component: PaymentDelete,
        canActivate: [authGuard]
    },
    {
        path: "**",
        redirectTo: "/login",
        pathMatch: "full"
    }
];
