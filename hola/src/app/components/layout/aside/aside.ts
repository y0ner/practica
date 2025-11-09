import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenuModule } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [CommonModule, PanelMenuModule, RouterLink],
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside implements OnInit {
    items: MenuItem[] | undefined;
    ngOnInit() {
        this.items = [
            { label: 'Cambio1', icon: 'pi pi-fw pi-box', routerLink: '/cambio1' },            { label: 'Cambio2', icon: 'pi pi-fw pi-box', routerLink: '/cambio2' },            { label: 'Cambio3', icon: 'pi pi-fw pi-box', routerLink: '/cambio3' }
        ];
    }
}
