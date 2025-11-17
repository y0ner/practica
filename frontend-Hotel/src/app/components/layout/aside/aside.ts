import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenu } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule, PanelMenu],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside implements OnInit {
    items: MenuItem[] | undefined;
    ngOnInit() {
        this.items = [
            { label: 'Hoteles', icon: 'pi pi-fw pi-box', routerLink: '/Hoteles' },            { label: 'Habitaciones', icon: 'pi pi-fw pi-box', routerLink: '/Habitaciones' },            { label: 'Tipos de habitación', icon: 'pi pi-fw pi-box', routerLink: '/Tipos de habitación' },            { label: 'Temporadas', icon: 'pi pi-fw pi-box', routerLink: '/Temporadas' },            { label: 'Tarifas', icon: 'pi pi-fw pi-box', routerLink: '/Tarifas' },            { label: 'Clientes', icon: 'pi pi-fw pi-box', routerLink: '/Clientes' },            { label: 'Reservas', icon: 'pi pi-fw pi-box', routerLink: '/Reservas' },            { label: 'Servicios', icon: 'pi pi-fw pi-box', routerLink: '/Servicios' },            { label: 'Pagos', icon: 'pi pi-fw pi-box', routerLink: '/Pagos' }
        ];
    }
}
