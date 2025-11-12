#!/bin/bash

# Script principal que carga las partes y ejecuta el menú.

# --- Cargar los scripts con las funciones ---
# Es importante usar "source" o "." para que las funciones y variables
# estén disponibles en el scope de este script principal.

echo "Cargando part1_setup.sh..."
source ./part1_setup.sh || { echo "Error cargando part1_setup.sh"; exit 1; }

echo "Cargando part3_auth.sh..."
source ./part3_auth.sh || { echo "Error cargando part3_auth.sh"; exit 1; }

echo "Cargando scripts de la Parte 4..."
source ./part4/models.sh || { echo "Error cargando part4/models.sh"; exit 1; }
source ./part4/services.sh || { echo "Error cargando part4/services.sh"; exit 1; }
source ./part4/components.sh || { echo "Error cargando part4/components.sh"; exit 1; }
source ./part4/html.sh || { echo "Error cargando part4/html.sh"; exit 1; }
source ./part4/create_components.sh || { echo "Error cargando part4/create_components.sh"; exit 1; } # <-- AQUÍ ESTÁ LA CORRECCIÓN
source ./part4/update_components.sh || { echo "Error cargando part4/update_components.sh"; exit 1; }
source ./part4/delete_components.sh || { echo "Error cargando part4/delete_components.sh"; exit 1; }
source ./part4/design_improvements.sh || { echo "Error cargando part4/design_improvements.sh"; exit 1; }
source ./part4/routing.sh || { echo "Error cargando part4/routing.sh"; exit 1; }
source ./part4/menu.sh || { echo "Error cargando part4/menu.sh"; exit 1; }

main_menu() {
    while true; do
        
        echo -e "\n${BLUE}========== MENÚ DE AUTOMATIZACIÓN ==========${NC}"
        echo -e "Los proyectos se buscarán y crearán en el directorio:"
        echo -e "${YELLOW}$(realpath "$PROJECTS_DIR")${NC}"
        if [ -n "$PROJECT_NAME" ]; then
            echo -e "Proyecto activo: ${GREEN}$PROJECT_NAME${NC}"
        fi
        echo ""
        echo "1. Seleccionar un proyecto existente"
        echo "2. Parte Básica con PrimeNG (Crear y configurar proyecto)"
        echo "3. Generar APIs y Rutas (Frontend)"
        echo "4. Implementar Autenticación y Autorización"
        echo "5. Generar Modelos y Servicios CRUD"
        echo "6. Iniciar servidor de desarrollo"
        echo "7. Salir"
        read -p "Elige una sección: " choice

        case $choice in
            1) select_existing_project; press_enter_to_continue ;;
            2) show_part1_menu; press_enter_to_continue ;;
            3) create_crud_apis; press_enter_to_continue ;;
            4) setup_authentication; press_enter_to_continue ;;
            5) show_part4_menu; press_enter_to_continue ;;
            6) start_server ;;
            7) echo "Saliendo..."; exit 0 ;;
            *) print_error "Opción no válida." ;;
        esac
    done
}

# --- Iniciar el script ---
main_menu