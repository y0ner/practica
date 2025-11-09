import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenu } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common'; // Importante para [model]

@Component({
  selector: 'app-aside',
  standalone: true,
  imports: [PanelMenu, CommonModule], // Añadido CommonModule
  templateUrl: './aside.html',
  styleUrl: './aside.css'
})
export class Aside implements OnInit {
items: MenuItem[] | undefined;
ngOnInit() {
        this.items = [
            {
        label: 'Clientes',
        icon: 'pi pi-fw pi-users',
      },
      {
        label: 'Tipo Productos',
        icon: 'pi pi-fw pi-qrcode',
      },
      {
        label: 'Productos',
        icon: 'pi pi-fw pi-shopping-bag',
      },
      {
        label: 'Ventas',
        icon: 'pi pi-fw pi-shopping-cart',
      }
        ];
    }
}
