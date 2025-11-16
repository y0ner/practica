#!/bin/bash

implement_panel_menu() {
    print_step "Implementando PanelMenu de PrimeNG en Aside"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    print_msg "Trabajando en el proyecto: $PROJECT_NAME"
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    read -p "Introduce el número de elementos de menú (tablas) que deseas crear: " num_tables
    if ! [[ "$num_tables" =~ ^[1-9][0-9]*$ ]]; then
        print_error "Por favor, introduce un número entero positivo."
        return 1
    fi

    menu_items_str=""
    declare -a table_names=()
    for (( i=1; i<=num_tables; i++ )); do
        read -p "Introduce el nombre para el elemento de menú #${i}: " table_name
        if [ -z "$table_name" ]; then
            print_error "El nombre no puede estar vacío."
            ((i--))
            continue
        fi

        table_names+=("$table_name")
        label="$(echo ${table_name:0:1} | tr '[:lower:]' '[:upper:]')${table_name:1}"
        
        item_str=$(cat <<ITEM
            {
                label: '${label}',
                icon: 'pi pi-fw pi-box',
            }
ITEM
)
        menu_items_str+="${item_str},"
    done

    menu_items_str=$(echo "${menu_items_str}" | sed 's/,$//')

    print_msg "Guardando nombres de las tablas en .table_names para uso futuro..."
    printf "%s\n" "${table_names[@]}" > .table_names

    print_msg "Actualizando src/app/components/layout/aside/aside.html"
    cat << 'EOF' > src/app/components/layout/aside/aside.html
<div class="card flex justify-center">
    <p-panelmenu [model]="items" class="w-full md:w-80"></p-panelmenu>
</div>
EOF

    print_msg "Actualizando src/app/components/layout/aside/aside.ts con ${num_tables} elementos"
    cat << END_OF_TS > src/app/components/layout/aside/aside.ts
import { Component, OnInit } from '@angular/core';
import { MenuItem } from 'primeng/api';
import { PanelMenu } from 'primeng/panelmenu';
import { CommonModule } from '@angular/common';

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
            ${menu_items_str}
        ];
    }
}
END_OF_TS

    print_success "PanelMenu implementado en Aside."
    cd - > /dev/null
}