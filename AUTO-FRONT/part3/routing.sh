#!/bin/bash

# Este archivo contiene la lógica para crear el AuthGuard y actualizar
# el archivo de rutas principal para proteger los componentes CRUD.

setup_auth_routing_and_guards() {
    print_step "Creando AuthGuard y actualizando rutas"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No se ha seleccionado un proyecto."
        return 1
    fi

    local project_path="$PROJECTS_DIR/$PROJECT_NAME"
    cd "$project_path" || { print_error "No se pudo acceder al directorio del proyecto."; return 1; }

    print_msg "Creando AuthGuard en src/app/guards/authguard.ts"
    mkdir -p src/app/guards
    cat << 'EOF' > src/app/guards/authguard.ts
import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = (route, state) => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isLoggedIn()) {
    return true;
  }

  router.navigate(['/login']);
  return false;
};
EOF
    print_success "AuthGuard creado."

    print_msg "Actualizando src/app/app.routes.ts con rutas protegidas"
    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Las rutas CRUD no se pueden proteger."
        return 1
    fi
    mapfile -t table_names < .table_names

    local crud_imports=""
    local crud_routes=""
    for table_name in "${table_names[@]}"; do
        local lower_name="$table_name"
        local capitalized_name="$(tr '[:lower:]' '[:upper:]' <<< ${lower_name:0:1})${lower_name:1}"
        crud_imports+=$(cat <<EOF
import { Getall as ${capitalized_name}Getall } from './components/${lower_name}/getall/getall';
import { Create as ${capitalized_name}Create } from './components/${lower_name}/create/create';
import { Update as ${capitalized_name}Update } from './components/${lower_name}/update/update';
import { Delete as ${capitalized_name}Delete } from './components/${lower_name}/delete/delete';
EOF
)
        crud_routes+=$(cat <<EOF
    { path: '${lower_name}', component: ${capitalized_name}Getall, canActivate: [authGuard] },
    { path: '${lower_name}/new', component: ${capitalized_name}Create, canActivate: [authGuard] },
    { path: '${lower_name}/edit/:id', component: ${capitalized_name}Update, canActivate: [authGuard] },
    { path: '${lower_name}/delete/:id', component: ${capitalized_name}Delete, canActivate: [authGuard] },
EOF
)
    done

    cat << EOF > src/app/app.routes.ts
import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { authGuard } from './guards/authguard';

// CRUD imports
${crud_imports}

export const routes: Routes = [
    { path: 'login', component: Login },
    { path: 'register', component: Register },
    { path: '', redirectTo: '/${table_names[0]}', pathMatch: 'full' },

    // CRUD routes
${crud_routes}

    { path: '**', redirectTo: '/login' }
];
EOF
    print_success "Rutas actualizadas y protegidas con AuthGuard."

    cd - > /dev/null
}