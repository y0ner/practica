import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenuModule } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common';
@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule, PanelMenuModule],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside implements OnInit {
    items: MenuItem[] | undefined;
    ngOnInit() {
        this.items = [
            { label: 'Hotel', icon: 'pi pi-fw pi-box', routerLink: '/Hotel' },            { label: 'TipoHabitacion', icon: 'pi pi-fw pi-box', routerLink: '/TipoHabitacion' },            { label: 'Habitacion', icon: 'pi pi-fw pi-box', routerLink: '/Habitacion' },            { label: 'Temporada', icon: 'pi pi-fw pi-box', routerLink: '/Temporada' },            { label: 'Tarifa', icon: 'pi pi-fw pi-box', routerLink: '/Tarifa' },            { label: 'Cliente', icon: 'pi pi-fw pi-box', routerLink: '/Cliente' },            { label: 'Servicio', icon: 'pi pi-fw pi-box', routerLink: '/Servicio' },            { label: 'Reserva', icon: 'pi pi-fw pi-box', routerLink: '/Reserva' },            { label: 'Pago', icon: 'pi pi-fw pi-box', routerLink: '/Pago' }
        ];
    }
}
