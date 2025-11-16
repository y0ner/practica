#!/bin/bash

# ==========================================
# 🚀 Asistente Interactivo de Proyecto Node.js (WSL)
# Autor: Yoner
# ==========================================

# Obtener el directorio absoluto del script para que las rutas no se rompan al cambiar de directorio
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Crear el directorio de scripts si no existe
mkdir -p "$SCRIPT_DIR/scripts"

# Cargar utilidades (colores y función de pausa)
. "$SCRIPT_DIR/scripts/utils.sh"

# Asegurar que todos los scripts sean ejecutables
chmod +x "$SCRIPT_DIR/scripts/"*.sh

last_option_used="Ninguna"

# ===============================
# 🧭 MENÚ PRINCIPAL
# ===============================
while true; do
  
  echo -e "${YELLOW}==============================================${NC}"
  echo -e "${CYAN}     🧩 Asistente de Proyecto Node.js (WSL)    ${NC}"
  echo -e "${YELLOW}==============================================${NC}"
  echo -e "${GREEN}Proyecto Actual: $(pwd)${NC}"
  echo -e "${YELLOW}----------------------------------------------${NC}"
  echo -e "00. Seleccionar un proyecto existente"
  echo -e "1. Instalar wget"
  echo -e "2. Instalar NVM"
  echo -e "3. Instalar Node.js"
  echo -e "4. Crear carpeta del proyecto"
  echo -e "5. Abrir Visual Studio Code"
  echo -e "6. Inicializar proyecto Node + TypeScript"
  echo -e "7. Instalar dependencias core"
  echo -e "8. Crear estructura de carpetas"
  echo -e "9. Crear archivos base (server.ts / config/index.ts)"
  echo -e "10. Instalar dependencias de base de datos"
  echo -e "11. Crear archivo .env"
  echo -e "12. Crear configuración de base de datos"
  echo -e "13. Instalar dependencias de autenticación"
  echo -e "14. Ejecutar servidor (npm run dev)"
  echo -e "15. Copiar modelos de autorización"
  echo -e "16. Crear modelos de proyecto (Interactivo)"
  echo -e "17. Copiar controladores de autorización"
  echo -e "18. Crear controladores de proyecto"
  echo -e "19. --Ahora debes copiar y pegar src/routes/authorization (manualmente)"
  echo -e "20. --Ahora debes haces las rutas de el proyecto (manualmente)"
  echo -e "21. Crear src/routes/index.ts (cambia las lineas de errores por los correctos)"
  echo -e "22. Actualizar src/config/index.ts con rutas"
  echo -e "23. --Instalar la extension Rest Client (manualmente)"
  echo -e "24. --Ahora debes copiar y pegar src/http/authorization/ (manualmente)"
  echo -e "25. --Ahora debes hacer los http de tu project (manualmente)"
  echo -e "26. Instalar faker y crear script de población de datos"
  echo -e "27. Actualizar src/config/index.ts (final)"
  echo -e "28. Crear middleware de autenticación (auth.ts)"
  echo -e "0. Salir"
  echo -e "${YELLOW}==============================================${NC}"
  echo -e "${CYAN}Última opción utilizada: ${last_option_used}${NC}"
  read -p "Selecciona una opción: " opcion

  # Guardar la última opción válida utilizada (pasos de configuración)
  if [[ "$opcion" =~ ^[0-9]+$ ]] && [ "$opcion" -ge 1 ] && [ "$opcion" -le 28 ]; then
      last_option_used=$opcion
  fi

  case $opcion in
    00)
      selected_project=$("$SCRIPT_DIR/scripts/00_select_project.sh")
      if [ -n "$selected_project" ]; then
        cd "../$selected_project" || exit
        echo -e "${GREEN}✅ Directorio de trabajo cambiado a: $(pwd)${NC}"
      fi
      pause
      ;;
    1) "$SCRIPT_DIR/scripts/1_install_wget.sh" ;;
    2) "$SCRIPT_DIR/scripts/2_install_nvm.sh" ;;
    3) "$SCRIPT_DIR/scripts/3_install_node.sh" ;;
    4)
      folder_name=$("$SCRIPT_DIR/scripts/4_create_project_folder.sh")
      if [ -n "$folder_name" ] && [ -d "../$folder_name" ]; then
        cd "../$folder_name" || exit
        echo -e "${GREEN}✅ Directorio de trabajo cambiado a: $(pwd)${NC}"
      fi
      pause
      ;;
    5) "$SCRIPT_DIR/scripts/5_open_vscode.sh" ;;
    6) "$SCRIPT_DIR/scripts/6_init_node_project.sh" ;;
    7) "$SCRIPT_DIR/scripts/7_install_core_deps.sh" ;;
    8) "$SCRIPT_DIR/scripts/8_create_folder_structure.sh" ;;
    9) "$SCRIPT_DIR/scripts/9_create_base_files.sh" ;;
    10) "$SCRIPT_DIR/scripts/10_install_db_deps.sh" ;;
    11) "$SCRIPT_DIR/scripts/11_create_env_file.sh" ;;
    12) "$SCRIPT_DIR/scripts/12_create_config_db.sh" ;;
    13) "$SCRIPT_DIR/scripts/13_install_auth_deps.sh" ;;
    14) "$SCRIPT_DIR/scripts/14_run_server.sh" ;;
    15) "$SCRIPT_DIR/scripts/15_copy_auth_models.sh" ;;
    16) "$SCRIPT_DIR/scripts/16_create_models_interactive.sh" ;;
    17) "$SCRIPT_DIR/scripts/17_copy_auth_controllers.sh" ;;
    18) "$SCRIPT_DIR/scripts/18_create_controllers.sh" ;;
    21) "$SCRIPT_DIR/scripts/21_create_routes_index.sh" ;;
    22) "$SCRIPT_DIR/scripts/22_update_config_with_routes.sh" ;;
    27) "$SCRIPT_DIR/scripts/27_update_config_final.sh" ;;
    26) "$SCRIPT_DIR/scripts/26_install_faker_and_populate.sh" ;;
    28) "$SCRIPT_DIR/scripts/28_create_auth_middleware.sh" ;;
    0) echo "Saliendo..."; exit 0 ;;
    *) echo "Opción inválida."; pause ;;
  esac
done
