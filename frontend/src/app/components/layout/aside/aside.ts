import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenu } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common'; // Importante para [model]

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
                        {
                label: 'Hola',
                icon: 'pi pi-fw pi-box',
            },            {
                label: 'Hola1',
                icon: 'pi pi-fw pi-box',
            },            {
                label: 'Hola2',
                icon: 'pi pi-fw pi-box',
            }
        ];
    }
}
