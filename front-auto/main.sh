#!/bin/bash

# Script principal que carga las partes y ejecuta el menú.

# --- Cargar los scripts con las funciones ---
# Es importante usar "source" o "." para que las funciones y variables
# estén disponibles en el scope de este script principal.

echo "Cargando Parte 1: Gestión de Proyectos..."
source ./part1.sh || { echo "Error cargando part1.sh"; exit 1; }
echo "Cargando Parte 2: Configuración Básica..."
source ./part2.sh || { echo "Error cargando part2.sh"; exit 1; }
echo "Cargando Parte 3: APIs y Rutas..."
source ./part3.sh || { echo "Error cargando part3.sh"; exit 1; }
echo "Cargando Parte 4: Autenticación..."
source ./part4.sh || { echo "Error cargando part4.sh"; exit 1; }
echo "Cargando Parte 5: Lógica CRUD..."
source ./part5.sh || { echo "Error cargando part5.sh"; exit 1; }

main_menu() {
    local last_choice=""
    while true; do
        
        echo -e "\n${BLUE}========== MENÚ DE AUTOMATIZACIÓN ==========${NC}"
        echo -e "Los proyectos se buscarán y crearán en el directorio:"
        echo -e "${YELLOW}$(realpath "$PROJECTS_DIR")${NC}"
        if [ -n "$PROJECT_NAME" ]; then
            echo -e "Proyecto activo: ${GREEN}$PROJECT_NAME${NC}"
        fi
        if [ -n "$last_choice" ]; then
            echo -e "Última sección completada: ${GREEN}${last_choice}${NC}"
        fi
        echo ""
        echo "1. Seleccionar proyecto existente"
        echo "2. Parte 2: Configuración Básica (PrimeNG, Tailwind, etc.)"
        echo "3. Parte 3: Generar APIs y Rutas (Frontend)"
        echo "4. Parte 4: Implementar Autenticación y Autorización"
        echo "5. Parte 5: Generar Lógica y Componentes CRUD"
        echo "6. Iniciar servidor de desarrollo"
        echo "7. Salir"
        read -p "Elige una sección: " choice

        case $choice in
            1) select_existing_project; last_choice="1"; press_enter_to_continue ;;
            2) show_part1_menu; last_choice="2"; press_enter_to_continue ;;
            3) create_crud_apis; last_choice="3"; press_enter_to_continue ;;
            4) setup_authentication; last_choice="4"; press_enter_to_continue ;;
            5) show_part4_menu; last_choice="5"; press_enter_to_continue ;;
            6) start_server; last_choice="6" ;;
            7) echo "Saliendo..."; exit 0 ;;
            *) print_error "Opción no válida."; press_enter_to_continue ;;
        esac
    done
}

# --- Iniciar el script ---
main_menu