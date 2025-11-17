#!/bin/bash

# Este archivo contiene la lógica para actualizar los componentes principales
# del layout (app.ts y app.html) para que reaccionen al estado de autenticación.

update_main_layout_for_auth() {
    print_step "Actualizando layout principal para autenticación"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No se ha seleccionado un proyecto."
        return 1
    fi

    local project_path="$PROJECTS_DIR/$PROJECT_NAME"

    print_msg "Actualizando app.ts para inyectar AuthService"
    cat << 'EOF' > "$project_path/src/app/app.ts"
import { Component, signal } from '@angular/core';
import { RouterOutlet } from '@angular/router';
import { CommonModule } from '@angular/common';
import { Aside } from './components/layout/aside/aside';
import { Header } from './components/layout/header/header';
import { Footer } from './components/layout/footer/footer';
import { AuthService } from './services/auth.service';

@Component({
  selector: 'app-root',
  standalone: true,
  imports: [RouterOutlet, Header, Footer, Aside, CommonModule],
  templateUrl: './app.html',
  styleUrl: './app.css'
})
export class App {
  protected readonly title = signal('appfront');

  constructor(public authService: AuthService) {}
}
EOF

    print_msg "Actualizando app.html para mostrar layout condicionalmente"
    cat << 'EOF' > "$project_path/src/app/app.html"
<!-- El layout (header, aside) solo se muestra si el usuario está autenticado -->
<ng-container *ngIf="authService.authState$ | async">
  <header class="h-16 bg-white border-b border-gray-200 flex items-center w-full shadow-sm z-10 fixed top-0 left-0 right-0">
    <app-header class="w-full"></app-header>
  </header>
  <aside class="w-64 bg-white border-r border-gray-200 shadow-sm fixed top-16 bottom-0 left-0">
    <app-aside></app-aside>
  </aside>
</ng-container>

<main class="bg-gray-50 min-h-screen" [class.pl-64]="authService.authState$ | async" [class.pt-16]="authService.authState$ | async">
  <div class="p-6"> <router-outlet></router-outlet> </div>
</main>
EOF

    print_success "Layout principal actualizado."
}