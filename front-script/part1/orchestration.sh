#!/bin/bash

run_all_steps() {
    print_step "EJECUTANDO TODOS LOS PASOS DE LA PARTE 1"
    check_prerequisites || return 1
    create_angular_project || return 1
    install_tailwind || return 1
    install_primeng || return 1
    create_layout_components || return 1
    implement_panel_menu || return 1

    print_success "¡Configuración completa del Frontend Básico terminada!"
    print_msg "Puedes iniciar el servidor con: cd ${PROJECTS_DIR}/${PROJECT_NAME} && ng serve --open"
}

start_server() {
    print_step "Iniciando servidor de desarrollo"
    if [ -z "$PROJECT_NAME" ]; then
        print_error "No has seleccionado un proyecto. Por favor, crea o selecciona uno primero."
        return 1
    fi
    cd "$PROJECTS_DIR/$PROJECT_NAME" || { print_error "No se encontró el directorio del proyecto '$PROJECT_NAME'."; return 1; }
    print_msg "Ejecutando 'ng serve --open'. Presiona CTRL+C para detener."
    ng serve --open

    cd - > /dev/null
}

show_part1_menu() {
    while true; do
        echo -e "\n${YELLOW}===== SECCIÓN 1: Parte Básica con PrimeNG =====${NC}"
        echo "1. Verificar requisitos (Node, Angular CLI)"
        echo "2. Crear proyecto Angular"
        echo "3. Instalar Tailwind CSS"
        echo "4. Instalar PrimeNG y Tema"
        echo "5. Crear componentes de Layout (Header, Aside, Footer)"
        echo "6. Implementar PanelMenu en Aside"
        echo "7. ${GREEN}Ejecutar TODOS los pasos (1-6) de esta sección${NC}"
        echo "8. Volver al Menú Principal"
        read -p "Elige una opción: " sub_choice

        case $sub_choice in
            1) check_prerequisites; press_enter_to_continue ;;
            2) create_angular_project; press_enter_to_continue ;;
            3) install_tailwind; press_enter_to_continue ;;
            4) install_primeng; press_enter_to_continue ;;
            5) create_layout_components; press_enter_to_continue ;;
            6) implement_panel_menu; press_enter_to_continue ;;
            7) run_all_steps; press_enter_to_continue ;;
            8) break ;;
            *) print_error "Opción no válida."; press_enter_to_continue ;;
        esac
    done
}