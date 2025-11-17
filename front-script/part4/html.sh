#!/bin/bash

# Este archivo contiene la lógica para la creación de las plantillas HTML para los componentes 'getall'.

create_getall_html() {
    print_step "Creación de plantillas HTML para componentes 'getall'"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero la creación de modelos y servicios."
        return 1
    fi

    mapfile -t table_names < .table_names

    for table_name in "${table_names[@]}"; do
        print_step "Configurando plantilla HTML para la entidad: '$table_name'"

        # Intentar obtener el nombre del modelo desde el archivo de mapeo
        local model_name=$(grep "^${table_name}:" .model_map | cut -d':' -f2)

        if [ -z "$model_name" ]; then
            print_warning "No se encontró un modelo para '${table_name}'. Por favor, introdúcelo manualmente."
            while true; do # CORRECCIÓN: Se añadió 'do' para completar la sintaxis del bucle.
                read -p "Introduce el nombre del MODELO en singular y capitalizado (ej. Client, Product): " model_name
                if [[ "$model_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                    break
                else
                    print_error "El nombre debe empezar con mayúscula y solo contener caracteres alfanuméricos."
                fi
            done
        else
            print_info "Modelo encontrado para '${table_name}': '${model_name}'"
        fi

        local entity_name_singular_lower=$(echo "$model_name" | tr '[:upper:]' '[:lower:]')
        local entity_name_plural_capitalized="$(echo "${table_name:0:1}" | tr '[:lower:]' '[:upper:]')${table_name:1}"

        local headers=""
        local body_cells=""
        local colspan=2 # 1 para ID, 1 para Acciones

        # ID siempre está
        headers+="                <th pSortableColumn=\"id\">\n                    ID <p-sortIcon field=\"id\"></p-sortIcon>\n                </th>\n"
        body_cells+="                <td>{{ ${entity_name_singular_lower}.id }}</td>\n"

        # --- NUEVA LÓGICA DE EXCLUSIÓN ---

        # 1. Leer los atributos desde el archivo del modelo
        local model_file="src/app/models/${table_name}.ts"
        if [ ! -f "$model_file" ]; then
            print_error "No se encontró el archivo del modelo en '$model_file'. No se pueden determinar los atributos."
            continue
        fi

        # Extraer atributos, limpiar espacios, quitar '?' y excluir 'id', 'status' y líneas vacías.
        local all_attributes=($(sed -n '/ResponseI {/,/}/p' "$model_file" | grep ':' | sed -e 's/^\s*//' -e 's/?:.*//' -e 's/:.*//' | grep -v -E '^(id|status)$' | sort -u))
        
        local attributes_to_show=("${all_attributes[@]}")
        local excluded_attributes=()

        # 2. Bucle interactivo para que el usuario elija qué atributos excluir
        while true; do
            echo -e "\n${YELLOW}Los siguientes atributos se mostrarán en la tabla para '${model_name}':${NC}"
            echo "  ${attributes_to_show[*]}"
            echo -e "${YELLOW}Selecciona un atributo que desees OCULTAR (o 'Finalizar'):${NC}"
            
            local options=("${attributes_to_show[@]}" "Finalizar - Generar la tabla")
            
            select attr_to_exclude in "${options[@]}"; do
                if [[ "$attr_to_exclude" == "Finalizar - Generar la tabla" ]]; then
                    break 2 # Rompe ambos bucles (select y while)
                elif [ -n "$attr_to_exclude" ]; then
                    excluded_attributes+=("$attr_to_exclude")
                    # Reconstruir la lista de atributos a mostrar
                    local temp_attrs=()
                    for item in "${attributes_to_show[@]}"; do
                        if [[ "$item" != "$attr_to_exclude" ]]; then
                            temp_attrs+=("$item")
                        fi
                    done
                    attributes_to_show=("${temp_attrs[@]}")
                    break # Rompe el 'select' y vuelve a mostrar el menú 'while' actualizado
                else
                    print_error "Opción no válida. Inténtalo de nuevo."
                fi
            done
        done

        # 3. Construir las cabeceras y celdas del cuerpo basadas en los atributos que quedaron
        for attr_name in "${attributes_to_show[@]}"; do
            local attr_header=$(echo "$attr_name" | sed -e 's/_/ /g' -e 's/\b\(.\)/\u\1/g') # Reemplaza '_' con espacio y capitaliza
            headers+="                <th pSortableColumn=\"${attr_name}\">\n                    ${attr_header} <p-sortIcon field=\"${attr_name}\"></p-sortIcon>\n                </th>\n"
            body_cells+="                <td>{{ ${entity_name_singular_lower}.${attr_name} }}</td>\n"
            ((colspan++))
        done

        local html_file_content
        html_file_content=$(cat <<EOF
<div class="card p-8">
    <div class="flex justify-between items-center mb-4">
        <h2 class="text-2xl font-bold">Gestión de ${entity_name_plural_capitalized}</h2>
        <p-button
            label="Nuevo ${model_name}"
            icon="pi pi-plus"
            [routerLink]="['/${table_name}/new']"
            styleClass="p-button-success"
        ></p-button>
    </div>

    <p-table 
        [value]="${table_name}" 
        [loading]="loading"
        [paginator]="true"
        [rows]="10"
        [showCurrentPageReport]="true"
        currentPageReportTemplate="Mostrando {first} a {last} de {totalRecords} registros"
        [rowsPerPageOptions]="[5, 10, 25, 50]"
        dataKey="id"
        styleClass="p-datatable-striped"
        [tableStyle]="{'min-width': '50rem'}"
    >
        <ng-template pTemplate="header">
            <tr>
${headers}                <th class="text-center">Acciones</th>
            </tr>
        </ng-template>

        <ng-template pTemplate="body" let-${entity_name_singular_lower}>
            <tr>
${body_cells}                <td class="text-center">
                    <div class="flex justify-center gap-2">
                        <p-button icon="pi pi-pencil" [routerLink]="['/${table_name}/edit', ${entity_name_singular_lower}.id]" styleClass="p-button-rounded p-button-text p-button-warning" pTooltip="Editar" tooltipPosition="top"></p-button>
                        <p-button icon="pi pi-trash" (onClick)="confirmDelete(${entity_name_singular_lower})" styleClass="p-button-rounded p-button-text p-button-danger" pTooltip="Eliminar" tooltipPosition="top"></p-button>
                    </div>
                </td>
            </tr>
        </ng-template>

        <ng-template pTemplate="emptymessage">
            <tr>
                <td colspan="${colspan}" class="text-center p-4">No se encontraron registros</td>
            </tr>
        </ng-template>
    </p-table>
</div>

<p-confirmDialog></p-confirmDialog>
<p-toast></p-toast>
EOF
)
        local html_filename="src/app/components/${table_name}/getall/getall.html"
        echo -e "$html_file_content" > "$html_filename"
        print_success "Plantilla HTML creada en: $html_filename"
    done

    print_success "Todas las plantillas HTML 'getall' han sido creadas."
    cd - > /dev/null
}