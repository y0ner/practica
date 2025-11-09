#!/bin/bash

# Script principal que carga las partes y ejecuta el menú.

# --- Cargar los scripts con las funciones ---
# Es importante usar "source" o "." para que las funciones y variables
# estén disponibles en el scope de este script principal.

echo "Cargando part1_setup.sh..."
source ./part1_setup.sh
echo "Cargando part2_crud.sh..."
source ./part2_rutas.sh
echo "Cargando part3_auth.sh..."
source ./part3_auth.sh
echo "Cargando part4_client_crud.sh..."
source ./part4_crud.sh

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
            3) show_part2_menu; press_enter_to_continue ;;
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