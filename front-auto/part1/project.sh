#!/bin/bash

select_existing_project() {
    print_step "Seleccionar un proyecto existente"
    print_msg "Buscando proyectos (directorios) en: $(realpath "$PROJECTS_DIR")"
    
    projects=()
    while IFS= read -r line; do projects+=("$line"); done < <(find "$PROJECTS_DIR" -maxdepth 1 -mindepth 1 -type d -not -name ".*" -printf "%f\n")

    if [ ${#projects[@]} -eq 0 ]; then
        print_error "No se encontraron directorios de proyectos en la ubicación actual."
        print_msg "Por favor, primero crea un proyecto con la opción del menú."
        return 1
    fi

    echo "Se encontraron los siguientes proyectos:"
    i=0
    for dir in "${projects[@]}"; do
        echo "  $((i+1)). $dir"
        i=$((i+1))
    done

    read -p "Elige el número del proyecto en el que quieres trabajar: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#projects[@]} ]; then
        PROJECT_NAME="${projects[$((choice-1))]}"
        print_success "Proyecto activo establecido a: '$PROJECT_NAME'"
    else
        print_error "Selección no válida."
        return 1
    fi
}

create_angular_project() {
    read -p "Introduce el nombre para el nuevo proyecto Angular: " project_name
    if [ -z "$project_name" ]; then
        print_error "El nombre del proyecto no puede estar vacío."
        return 1
    fi

    print_step "Creando proyecto Angular '$project_name'"
    if [ -d "$PROJECTS_DIR/$project_name" ]; then
        print_error "El directorio '$project_name' ya existe. Por favor, elimínalo o cámbiale el nombre."
        return 1
    fi

    local original_dir
    original_dir=$(pwd)

    cd "$PROJECTS_DIR" || { print_error "No se pudo acceder al directorio de proyectos."; return 1; }

    ng new "$project_name" --routing=true --style=css --standalone=true --skip-install
    if [ $? -ne 0 ]; then
        print_error "Falló la creación del proyecto Angular."
        cd "$original_dir"
        return 1
    fi
    
    PROJECT_NAME="$project_name"
    print_success "Proyecto activo establecido a: '$PROJECT_NAME'"
    
    cd "$PROJECT_NAME" || { print_error "No se pudo entrar al directorio del nuevo proyecto."; cd "$original_dir"; return 1; }
    print_success "Proyecto '$project_name' creado. Instalando dependencias..."
    npm install
    print_success "Dependencias de Angular instaladas."
    cd "$original_dir"
}