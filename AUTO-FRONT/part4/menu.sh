#!/bin/bash
# Este archivo contiene la función para mostrar el menú de la Parte 4.
show_part4_menu() {
    while true; do
        echo -e "\n${YELLOW}===== SECCIÓN 5: Generación de Modelos y Servicios =====${NC}"
        echo "1. Crear/Sobrescribir Modelos (Interfaces)"
        echo "2. Crear/Sobrescribir Servicios CRUD"
        echo "3. Enlazar Componentes 'getall' (Mostrar y Eliminar)"
        echo "4. Crear/Sobrescribir Plantillas HTML para 'getall'"
        echo "5. Generar/Sobrescribir Archivo de Rutas (app.routes.ts)"
        echo "6. (Re)Configurar Archivo Principal (app.config.ts)"
        echo "7. Volver al Menú Principal"
        read -p "Elige una opción: " sub_choice

        case $sub_choice in
            1) create_dynamic_models; press_enter_to_continue ;;
            2) create_dynamic_services; press_enter_to_continue ;;
            3) link_getall_components; press_enter_to_continue ;;
            4) create_getall_html; press_enter_to_continue ;;
            5) update_app_routes; press_enter_to_continue ;;
            6) setup_app_config; press_enter_to_continue ;;
            7) break ;;
            *) print_error "Opción no válida." ;;
        esac
    done
}