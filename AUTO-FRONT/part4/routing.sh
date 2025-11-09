#!/bin/bash

# Este archivo contiene la lógica para generar dinámicamente el archivo de rutas principal (app.routes.ts).

update_app_routes() {
    print_step "Actualizando el archivo de rutas principal (src/app/routes.ts)"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    if [ ! -f ".table_names" ] || [ ! -f ".model_map" ]; then
        print_error "No se encontraron los archivos '.table_names' o '.model_map'. Por favor, ejecuta primero la creación de modelos."
        return 1
    fi

    mapfile -t table_names < .table_names

    local imports_block=""
    local routes_block=""

    print_info "Generando rutas para las siguientes entidades: ${table_names[*]}"

    for table_name in "${table_names[@]}"; do
        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)
        if [ -z "$model_name" ]; then
            print_warning "No se encontró mapeo de modelo para '${table_name}'. Saltando generación de rutas para esta entidad."
            continue
        fi

        # Capitalizar el nombre del modelo para los alias (ej. Client)
        local capitalized_model_name="$(echo "${model_name:0:1}" | tr '[:lower:]' '[:upper:]')${model_name:1}"

        # Generar bloque de imports
        imports_block+=$(cat <<EOF

// ${capitalized_model_name} components with aliases
import { Getall as ${capitalized_model_name}Getall } from './components/${table_name}/getall/getall';
import { Create as ${capitalized_model_name}Create } from './components/${table_name}/create/create';
import { Update as ${capitalized_model_name}Update } from './components/${table_name}/update/update';
import { Delete as ${capitalized_model_name}Delete } from './components/${table_name}/delete/delete';
EOF
)

        # Generar bloque de rutas
        routes_block+=$(cat <<EOF
    {
        path: "${table_name}",
        component: ${capitalized_model_name}Getall,
        canActivate: [AuthGuard]
    },
    {
        path: "${table_name}/new",
        component: ${capitalized_model_name}Create,
        canActivate: [AuthGuard]
    },
    {
        path: "${table_name}/edit/:id",
        component: ${capitalized_model_name}Update,
        canActivate: [AuthGuard]
    },
    {
        path: "${table_name}/delete/:id",
        component: ${capitalized_model_name}Delete,
        canActivate: [AuthGuard]
    },
EOF
)
    done

    # Construir el contenido final del archivo de rutas
    local routes_file_content
    routes_file_content=$(cat <<EOF
import { Routes } from '@angular/router';
import { Login } from './components/auth/login/login';
import { Register } from './components/auth/register/register';
import { AuthGuard } from './guards/authguard';
${imports_block}

export const routes: Routes = [
    { 
        path: '', 
        redirectTo: '/login', 
        pathMatch: 'full' 
    },
    {
        path: "login",
        component: Login
    },
    {
        path: "register",
        component: Register
    },
${routes_block}
    {
        path: "**",
        redirectTo: "/login",
        pathMatch: "full"
    }
];
EOF
)

    # Escribir el archivo
    local routes_filename="src/app/app.routes.ts"
    echo -e "$routes_file_content" > "$routes_filename"
    print_success "Archivo de rutas actualizado exitosamente en: ${routes_filename}"

    # Volver al directorio original
    cd - > /dev/null
}

setup_app_config() {
    print_step "Verificando y actualizando 'src/app/app.config.ts'"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    local config_file="src/app/app.config.ts"

    if [ ! -f "$config_file" ]; then
        print_error "El archivo '$config_file' no existe. No se puede modificar."
        cd - > /dev/null
        return 1
    fi

    # 1. Añadir 'provideZoneChangeDetection' si no existe
    if ! grep -q "provideZoneChangeDetection" "$config_file"; then
        # Añade el provider al inicio del array 'providers'
        sed -i "/providers: \[/a \ \ \ \ provideZoneChangeDetection({ eventCoalescing: true })," "$config_file"
        # Añade el import si no existe
        if ! grep -q "provideZoneChangeDetection" "$config_file" | grep -q "import"; then
             sed -i "/import { ApplicationConfig } from '@angular\/core';/a import { provideZoneChangeDetection } from '@angular\/core';" "$config_file"
        fi
        print_info "'provideZoneChangeDetection' ha sido añadido a '$config_file'."
    else
        print_success "'provideZoneChangeDetection' ya existe en '$config_file'."
    fi

    # 2. Añadir 'provideBrowserGlobalErrorListeners' si no existe
    if ! grep -q "provideBrowserGlobalErrorListeners" "$config_file"; then
        # Añade el provider al inicio del array 'providers'
        sed -i "/providers: \[/a \ \ \ \ provideBrowserGlobalErrorListeners()," "$config_file"
        # Añade el import si no existe
        if ! grep -q "provideBrowserGlobalErrorListeners" "$config_file" | grep -q "import"; then
             sed -i "/import { ApplicationConfig } from '@angular\/core';/a import { provideBrowserGlobalErrorListeners } from '@angular\/core';" "$config_file"
        fi
        print_info "'provideBrowserGlobalErrorListeners' ha sido añadido a '$config_file'."
    else
        print_success "'provideBrowserGlobalErrorListeners' ya existe en '$config_file'."
    fi

    cd - > /dev/null
}