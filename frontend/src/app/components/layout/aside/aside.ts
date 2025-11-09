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
            {
                label: 's'
                icon: 'pi pi-fw pi-box'
                routerLink: '/s'
            }
        ];
    }
}
