#!/bin/bash

# Este archivo contiene la lógica para la creación dinámica de modelos (interfaces) de Angular.

create_dynamic_models() {
    print_step "Creación dinámica de Modelos (Interfaces)"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }

    # Verificar si el archivo con los nombres de las tablas existe
    if [ ! -f ".table_names" ]; then
        print_error "No se encontró el archivo '.table_names'. Por favor, ejecuta primero el paso 'Implementar PanelMenu en Aside' (Opción 6, Sección 1)."
        return 1
    fi

    # Leer los nombres de las tablas
    mapfile -t table_names < .table_names
    print_msg "Se crearán modelos para las siguientes tablas: ${table_names[*]}"

    # Limpiar/crear el archivo de mapeo de modelos al inicio
    > .model_map

    mkdir -p src/app/models

    for table_name in "${table_names[@]}"; do
        print_step "Configurando modelo para la tabla: '$table_name'"

        # 1. Preguntar por el nombre del modelo en singular y capitalizado
        local model_name
        while true; do
            read -p "Introduce el nombre para el modelo en singular y capitalizado (ej. Client, Product): " model_name
            if [[ "$model_name" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
                break
            else
                print_error "El nombre debe empezar con mayúscula y solo contener caracteres alfanuméricos."
            fi
        done

        # Guardar el mapeo en el archivo
        echo "${table_name}:${model_name}" >> .model_map

        # 2. Preguntar por el número de atributos
        local num_attributes
        while true; do
            read -p "Introduce el número de atributos para '${model_name}' (excluyendo 'id' y 'status'): " num_attributes
            if [[ "$num_attributes" =~ ^[1-9][0-9]*$ ]]; then
                break
            else
                print_error "Por favor, introduce un número entero positivo."
            fi
        done

        local interface_body=""
        local response_interface_body=""

        # 3. Bucle para cada atributo
        for (( i=1; i<=num_attributes; i++ )); do
            echo -e "${YELLOW}--- Atributo #${i} ---${NC}"
            
            local attr_name
            read -p "Nombre del atributo: " attr_name

            # Preguntar por el tipo de dato
            local attr_type
            echo "Elige el tipo de dato para '${attr_name}':"
            select type_option in "string" "number" "boolean" "Date"; do
                case $type_option in
                    "string"|"number"|"boolean"|"Date")
                        attr_type=$type_option
                        break
                        ;;
                    *) echo "Opción no válida." ;;
                esac
            done

            # Construir la línea para la interfaz principal
            interface_body+="  ${attr_name}: ${attr_type};\n"

            # Preguntar si se incluye en la interfaz de respuesta
            local include_in_response
            read -p "¿Incluir '${attr_name}' en la interfaz de respuesta (ResponseI)? (s/n): " include_in_response
            if [[ "$include_in_response" =~ ^[sSyY]$ ]]; then
                response_interface_body+="  ${attr_name}: ${attr_type};\n"
            fi
        done

        # 4. Preguntar por claves foráneas
        while true; do
            read -p "¿El modelo '${model_name}' tiene una clave foránea (foreign key) hacia otro modelo? (s/n): " has_fk
            if [[ ! "$has_fk" =~ ^[sSyY]$ ]]; then
                break
            fi

            local fk_name
            read -p "Introduce el nombre base de la relación (ej. si es 'client_id', introduce 'client'): " fk_name

            local fk_attr_name="${fk_name}_id"
            local fk_attr_type="number"

            # Añadir a ambos cuerpos de interfaz, ya que el ID es necesario tanto para enviar como para recibir.
            interface_body+="  ${fk_attr_name}: ${fk_attr_type};\n"
            response_interface_body+="  ${fk_attr_name}: ${fk_attr_type};\n"
            print_info "Se ha añadido el campo de clave foránea: ${fk_attr_name}: ${fk_attr_type}"
        done

        # 4. Construir el contenido completo del archivo del modelo
        local model_file_content
        model_file_content=$(cat <<EOF
export interface ${model_name}I {
  id?: number;
${interface_body}  status: "ACTIVE" | "INACTIVE";
}


export interface ${model_name}ResponseI {
  id?: number;
${response_interface_body}}
EOF
)

        # 5. Escribir el archivo
        local model_filename="src/app/models/${table_name}.ts"
        echo -e "$model_file_content" > "$model_filename"
        print_success "Modelo creado exitosamente en: $model_filename"
    done

    print_success "Todos los modelos han sido creados."

    # Volvemos al directorio original del script
    local script_dir; script_dir=$(dirname "$(realpath "$0")")
    cd "$script_dir" || return
}