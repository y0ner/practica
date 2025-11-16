#!/bin/bash

# Este archivo contiene la lógica para actualizar el componente Header
# para que reaccione al estado de autenticación (menú dinámico, etc.).

update_header_for_auth() {
    print_step "Actualizando componente Header para autenticación"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No se ha seleccionado un proyecto."
        return 1
    fi

    local project_path="$PROJECTS_DIR/$PROJECT_NAME"

    print_msg "Actualizando header.ts con menú dinámico y estado de sesión"
    cat << 'EOF' > "$project_path/src/app/components/layout/header/header.ts"
import { Component, OnInit, OnDestroy } from '@angular/core';
import { Router } from '@angular/router';
import { RouterLink } from '@angular/router';
import { MenuItem } from 'primeng/api';
import { OverlayBadge } from 'primeng/overlaybadge';
import { TieredMenu } from 'primeng/tieredmenu';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../../services/auth.service';
import { Subscription } from 'rxjs';

@Component({
  selector: 'app-header',
  standalone: true,
  imports: [CommonModule, OverlayBadge, TieredMenu, RouterLink],
  templateUrl: './header.html',
  styleUrl: './header.css'
})
export class Header implements OnInit, OnDestroy {
  items: MenuItem[] = [];
  isLoggedIn = false;
  private authSubscription?: Subscription;

  constructor(
    private router: Router,
    public authService: AuthService
  ) {}

  ngOnInit() {
    this.authSubscription = this.authService.authState$.subscribe(isLoggedIn => {
      this.isLoggedIn = isLoggedIn;
      this.updateMenuItems();
    });
    this.isLoggedIn = this.authService.isLoggedIn();
    this.updateMenuItems();
  }

  ngOnDestroy() {
    this.authSubscription?.unsubscribe();
  }

  private updateMenuItems(): void {
    if (this.isLoggedIn) {
      this.items = [
        { label: 'Configuración', icon: 'pi pi-cog' },
        { label: 'Información', icon: 'pi pi-info-circle' },
        { separator: true },
        { label: 'Cerrar sesión', icon: 'pi pi-sign-out', command: () => this.logout() }
      ];
    } else {
      this.items = [
        { label: 'Iniciar sesión', icon: 'pi pi-sign-in', command: () => this.router.navigate(['/login']) },
        { label: 'Registrarse', icon: 'pi pi-user-plus', command: () => this.router.navigate(['/register']) }
      ];
    }
  }

  private logout(): void {
    this.authService.logout();
    this.router.navigate(['/login']);
  }
}
EOF

    print_msg "Actualizando header.html con botones y menú de usuario"
    cat << 'EOF' > "$project_path/src/app/components/layout/header/header.html"
<div class="w-full flex justify-end items-center gap-2 px-4">
    <button *ngIf="isLoggedIn" type="button" class="text-orange-500 bg-gray-100 hover:bg-gray-200 rounded-full shadow hover:shadow-lg flex items-center justify-center w-10 h-10">
        <p-overlaybadge value="2">
            <i class="pi pi-bell text-xl"></i>
        </p-overlaybadge>
    </button>
    <button type="button" class="text-orange-500 bg-gray-100 hover:bg-gray-200 rounded-full shadow hover:shadow-lg w-10 h-10 flex items-center justify-center" (click)="menu.toggle($event)">
        <i class="pi pi-user text-xl"></i>
    </button>
</div>
<p-tieredmenu #menu [model]="items" [popup]="true" />
EOF

    print_success "Componente Header actualizado."
}