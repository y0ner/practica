#!/bin/bash

create_crud_apis() {
    print_step "Generando componentes CRUD y rutas para las APIs"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # Verificar si el archivo con los nombres de las tablas existe
    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero el paso 'Implementar PanelMenu en Aside' (Opción 6 del menú anterior)."
        return 1
    fi

    # Leer los nombres de las tablas
    mapfile -t table_names < .table_names
    print_msg "Se generarán APIs para las siguientes tablas: ${table_names[*]}"

    local all_imports=""
    local all_routes=""
    local menu_items_str=""

    for table_name in "${table_names[@]}"; do
        local lower_name="$table_name"
        local capitalized_name="$(tr '[:lower:]' '[:upper:]' <<< ${lower_name:0:1})${lower_name:1}"

        print_msg "Generando componentes CRUD para '$capitalized_name'..."
        ng g c "components/${lower_name}/getall"
        ng g c "components/${lower_name}/create"
        ng g c "components/${lower_name}/update"
        ng g c "components/${lower_name}/delete"

        # ✅ Corrección 1: importar sin ".component"
        all_imports+=$(cat <<EOF
import { Getall as ${capitalized_name}Getall } from './components/${lower_name}/getall/getall';
import { Create as ${capitalized_name}Create } from './components/${lower_name}/create/create';
import { Update as ${capitalized_name}Update } from './components/${lower_name}/update/update';
import { Delete as ${capitalized_name}Delete } from './components/${lower_name}/delete/delete';
EOF
)

        # ✅ Corrección 2: rutas sin plural
        all_routes+=$(cat <<EOF
    { path: "${lower_name}", component: ${capitalized_name}Getall },
    { path: "${lower_name}/new", component: ${capitalized_name}Create },
    { path: "${lower_name}/edit/:id", component: ${capitalized_name}Update },
    { path: "${lower_name}/delete/:id", component: ${capitalized_name}Delete },
EOF
)

        # ✅ Corrección 3: aside con comas y sin plural
        menu_items_str+=$(cat <<EOF
            { label: '${capitalized_name}', icon: 'pi pi-fw pi-box', routerLink: '/${lower_name}' },
EOF
)
    done

    # Quitar la última coma para evitar errores
    menu_items_str=$(echo "${menu_items_str}" | sed 's/,$//')

    print_msg "Actualizando src/app/app.routes.ts..."
    cat << EOF > src/app/app.routes.ts
import { Routes } from '@angular/router';

${all_imports}

export const routes: Routes = [
    { path: '', redirectTo: '/', pathMatch: 'full' },
${all_routes}
];
EOF

    print_msg "Actualizando el menú en src/app/components/layout/aside/aside.ts..."
    cat << EOF > src/app/components/layout/aside/aside.ts
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
${menu_items_str}
        ];
    }
}
EOF

    print_success "Componentes CRUD, rutas e importaciones corregidas correctamente."

    # Volvemos al directorio original del script
    local script_dir; script_dir=$(dirname "$(realpath "$0")")
    cd "$script_dir" || return
}