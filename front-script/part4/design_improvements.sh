#!/bin/bash

# Este archivo contiene la lógica para aplicar mejoras de diseño y corregir la redirección post-login.

apply_design_improvements() {
    print_step "Aplicando Mejoras de Diseño y Correcciones de UI"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # --- 1. Corregir la redirección post-login y limpiar bordes de depuración ---
    print_msg "Corrigiendo app.html para usar el observable authState\$ y limpiando bordes..."

    cat << 'EOF' > src/app/app.html
<!-- El layout (header, aside) solo se muestra si el usuario está autenticado -->
<ng-container *ngIf="authService.authState$ | async">
  <header class="h-16 bg-white border-b border-gray-200 flex items-center w-full shadow-sm z-10 fixed top-0 left-0 right-0">
    <app-header class="w-full"></app-header>
  </header>
  <aside class="w-64 bg-white border-r border-gray-200 shadow-sm fixed top-16 bottom-0 left-0">
    <app-aside></app-aside>
  </aside>
</ng-container>

<!-- Contenedor principal para el contenido de la ruta -->
<!-- Se aplica el margen izquierdo y superior solo si está logueado -->
<main 
  class="bg-gray-50 min-h-screen"
  [class.pl-64]="authService.authState$ | async"
  [class.pt-16]="authService.authState$ | async">
  <div class="p-6">
    <router-outlet></router-outlet>
  </div>
</main>
EOF
    print_success "app.html actualizado con la lógica correcta y diseño mejorado."

    # --- 2. Actualizar app.ts para asegurar que el authService es público ---
    # Aunque ya debería serlo, esta es una buena práctica para confirmar.
    print_msg "Asegurando que authService es público en app.ts..."
    sed -i 's/constructor(authService: AuthService)/constructor(public authService: AuthService)/' src/app/app.ts
    print_success "app.ts verificado."

    # --- 3. Mejorar el HTML del componente de login para que sea más estético ---
    print_msg "Mejorando el diseño del componente de login..."
    cat << 'EOF' > src/app/components/auth/login/login.html
<div class="min-h-screen flex items-center justify-center bg-gray-100 p-4">
  <div class="max-w-md w-full">
    <p-card header="Iniciar Sesión" subheader="Bienvenido de nuevo" class="shadow-xl">
      <form [formGroup]="form" (ngSubmit)="submit()" class="space-y-6 p-4">
        <div class="flex flex-col">
          <label for="email" class="block mb-2 font-semibold text-gray-700">Email *</label>
          <input pInputText id="email" type="email" formControlName="email" class="w-full" placeholder="ejemplo@correo.com" />
          <small class="text-red-500 mt-1" *ngIf="form.get('email')?.invalid && form.get('email')?.touched">Email no válido</small>
        </div>

        <div class="flex flex-col">
          <label for="password" class="block mb-2 font-semibold text-gray-700">Contraseña *</label>
          <input pInputText id="password" type="password" formControlName="password" class="w-full" placeholder="Ingrese su contraseña" />
          <small class="text-red-500 mt-1" *ngIf="form.get('password')?.invalid && form.get('password')?.touched">La contraseña es requerida</small>
        </div>

        <div class="flex flex-col space-y-4 pt-4">
          <button pButton type="submit" class="w-full" label="Iniciar Sesión" icon="pi pi-sign-in" [loading]="loading" [disabled]="form.invalid || loading"></button>
          <a routerLink="/register" class="text-center text-blue-600 hover:underline text-sm">¿No tienes cuenta? Registrarse</a>
        </div>
      </form>
    </p-card>
  </div>
</div>
<p-toast></p-toast>
EOF
    print_success "Diseño del componente de login mejorado."

    print_success "Todas las mejoras de diseño y UI han sido aplicadas."
    cd - > /dev/null
}