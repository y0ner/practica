#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # Sin color

# --- Configuración ---
BASE_URL="http://localhost:4000"

# Variable global para almacenar el token
TOKEN=""
TOKEN_EXPIRATION_TIME=0

# --- Funciones de Utilidad ---

function check_jq() {
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}Error: 'jq' no está instalado. Es necesario para procesar las respuestas JSON.${NC}"
        echo "En Debian/Ubuntu: sudo apt-get install jq"
        echo "En macOS: brew install jq"
        exit 1
    fi
}

function press_enter_to_continue() {
    read -p "Presiona Enter para continuar..."
}

function make_request() {
    local method=$1
    local endpoint=$2
    local data=$3
    local headers=("-H" "Content-Type: application/json")

    if [[ "$TOKEN" != "" ]]; then
        headers+=("-H" "Authorization: Bearer $TOKEN")
    fi

    if [[ "$method" == "GET" || "$method" == "DELETE" ]]; then
        curl -s -X "$method" "${headers[@]}" "$BASE_URL/api$endpoint"
    else
        curl -s -X "$method" "${headers[@]}" -d "$data" "$BASE_URL/api$endpoint"
    fi
}

# --- Funciones de Selección Inteligente ---

function select_from_list() {
    local endpoint=$1
    local title=$2
    local jq_query_display=$3
    local jq_query_id=$4

    echo -e "${CYAN}Obteniendo lista de ${title}...${NC}"
    local response=$(make_request "GET" "$endpoint")
    
    # Validar si la respuesta es un JSON válido con datos
    if ! echo "$response" | jq -e . > /dev/null 2>&1 || [[ $(echo "$response" | jq "$jq_query_display | length") -eq 0 ]]; then
        echo -e "${RED}No se encontraron ${title} o la respuesta de la API no es válida.${NC}"
        echo "Respuesta recibida:"
        echo "$response" | jq .
        return 1
    fi

    echo -e "Por favor, selecciona un@ de l@s siguientes ${title}:"
    echo "$response" | jq -r "$jq_query_display | .[] | \"\(.index + 1)) \(.text)\""
    
    read -p "Selecciona un número: " choice
    
    local selected_id=$(echo "$response" | jq -r --argjson idx $((choice - 1)) "$jq_query_id | .[$idx]")

    if [[ -z "$selected_id" || "$selected_id" == "null" ]]; then
        echo -e "${RED}Selección inválida.${NC}"
        return 1
    fi

    echo "$selected_id"
}

function select_user() {
    select_from_list "/users" "Usuarios" \
    '.users | to_entries | map({index: .key, text: "\(.value.name) (\(.value.email))"})' \
    '.users[$idx].id'
}

function select_role() {
    select_from_list "/roles" "Roles" \
    '.roles | to_entries | map({index: .key, text: .value.name})' \
    '.roles[$idx].id'
}

function select_resource() {
    select_from_list "/resources" "Recursos" \
    '.resources | to_entries | map({index: .key, text: "\(.value.method) \(.value.path)"})' \
    '.resources[$idx].id'
}

# --- Menús de Gestión ---

function user_menu() {
    while true; do
        echo -e "\n${BLUE}--- Gestión de Usuarios ---${NC}"
        echo "1. Ver todos los usuarios"
        echo "2. Crear un nuevo usuario (y verificar)"
        echo "3. Volver al menú principal"
        read -p "Elige una opción: " choice

        case $choice in
            1)
                echo -e "${YELLOW}### Obteniendo todos los usuarios...${NC}"
                make_request "GET" "/users" | jq .
                ;;
            2)
                echo -e "${YELLOW}### Creando un nuevo usuario...${NC}"
                read -p "Nombre de usuario: " username
                if [[ "$username" == "atras" ]]; then continue; fi

                read -p "Email: " email
                if [[ "$email" == "atras" ]]; then continue; fi

                read -s -p "Contraseña: " password
                echo ""
                read -p "Avatar (URL o path): " avatar
                
                local user_data
                user_data=$(printf '{"username": "%s", "email": "%s", "password": "%s", "avatar": "%s", "is_active": "ACTIVE"}' "$username" "$email" "$password" "$avatar")
                
                echo "Creando usuario..."
                local create_response
                create_response=$(make_request "POST" "/register" "$user_data")
                echo "$create_response" | jq .

                local new_user_id=$(echo "$create_response" | jq -r '.user_interface.id')
                if [[ "$new_user_id" != "null" && ! -z "$new_user_id" ]]; then
                    echo -e "${GREEN}Usuario creado con ID: $new_user_id. Verificando...${NC}"
                    make_request "GET" "/users/$new_user_id" | jq .
                else
                    echo -e "${RED}No se pudo crear el usuario.${NC}"
                fi
                ;;
            3) break ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
        press_enter_to_continue
    done
}

function role_menu() {
    while true; do
        echo -e "\n${BLUE}--- Gestión de Roles ---${NC}"
        echo "1. Ver todos los roles"
        echo "2. Crear un nuevo rol"
        echo "3. Volver al menú principal"
        read -p "Elige una opción: " choice

        case $choice in
            1)
                echo -e "${YELLOW}### Obteniendo todos los roles...${NC}"
                make_request "GET" "/roles" | jq .
                ;;
            2)
                read -p "Nombre del nuevo rol: " role_name
                if [[ "$role_name" == "atras" ]]; then continue; fi

                local role_data=$(printf '{"name": "%s", "is_active": "ACTIVE"}' "$role_name")
                echo -e "${YELLOW}### Creando rol '$role_name'...${NC}"
                make_request "POST" "/roles" "$role_data" | jq .
                ;;
            3) break ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
        press_enter_to_continue
    done
}

function resource_menu() {
    while true; do
        echo -e "\n${BLUE}--- Gestión de Recursos (Endpoints) ---${NC}"
        echo "1. Ver todos los recursos"
        echo "2. Crear un nuevo recurso"
        echo "3. Volver al menú principal"
        read -p "Elige una opción: " choice

        case $choice in
            1)
                echo -e "${YELLOW}### Obteniendo todos los recursos...${NC}"
                make_request "GET" "/resources" | jq .
                ;;
            2)
                read -p "Ruta del recurso (ej: /api/products/:id): " path
                if [[ "$path" == "atras" ]]; then continue; fi

                read -p "Método del recurso (GET, POST, PATCH, DELETE): " method
                if [[ "$method" == "atras" ]]; then continue; fi

                local resource_data=$(printf '{"path": "%s", "method": "%s", "is_active": "ACTIVE"}' "$path" "$method")
                echo -e "${YELLOW}### Creando recurso '$method $path'...${NC}"
                make_request "POST" "/resources" "$resource_data" | jq .
                ;;
            3) break ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
        press_enter_to_continue
    done
}

function role_user_menu() {
    while true; do
        echo -e "\n${BLUE}--- Asignación de Roles a Usuarios ---${NC}"
        echo "1. Ver todas las asignaciones"
        echo "2. Asignar un rol a un usuario"
        echo "3. Volver al menú principal"
        read -p "Elige una opción: " choice

        case $choice in
            1)
                echo -e "${YELLOW}### Obteniendo todas las asignaciones rol-usuario...${NC}"
                make_request "GET" "/roleUsers" | jq .
                ;;
            2)
                local user_id=$(select_user)
                [[ $? -ne 0 ]] && press_enter_to_continue && continue

                local role_id=$(select_role)
                [[ $? -ne 0 ]] && press_enter_to_continue && continue

                local assignment_data=$(printf '{"user_id": %s, "role_id": %s, "is_active": "ACTIVE"}' "$user_id" "$role_id")
                
                echo -e "${YELLOW}### Asignando rol ID $role_id a usuario ID $user_id...${NC}"
                make_request "POST" "/roleUsers" "$assignment_data" | jq .
                ;;
            3) break ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
        press_enter_to_continue
    done
}

function resource_role_menu() {
    while true; do
        echo -e "\n${BLUE}--- Asignación de Permisos (Recurso-Rol) ---${NC}"
        echo "1. Ver todas las asignaciones de permisos"
        echo "2. Asignar un permiso a un rol"
        echo "3. Probar endpoints públicos (sin token)"
        echo "4. Volver al menú principal"
        read -p "Elige una opción: " choice

        case $choice in
            1)
                echo -e "${YELLOW}### Obteniendo todas las asignaciones recurso-rol...${NC}"
                make_request "GET" "/resourceRoles" | jq .
                ;;
            2)
                local resource_id=$(select_resource)
                [[ $? -ne 0 ]] && press_enter_to_continue && continue
                local resource_name=$(make_request "GET" "/resources/$resource_id" | jq -r '"\(.method) \(.path)"')

                local role_id=$(select_role)
                [[ $? -ne 0 ]] && press_enter_to_continue && continue
                local role_name=$(make_request "GET" "/roles/$role_id" | jq -r '.name')

                local assignment_data=$(printf '{"resource_id": %s, "role_id": %s, "is_active": "ACTIVE"}' "$resource_id" "$role_id")
                
                echo -e "${YELLOW}### Asignando permiso '${resource_name}' al rol '${role_name}'...${NC}"
                make_request "POST" "/resourceRoles" "$assignment_data" | jq .
                ;;
            3)
                echo -e "${CYAN}--- Probando Endpoints Públicos de Resource-Role ---${NC}"
                local original_token=$TOKEN
                TOKEN="" # Desactivar token temporalmente
                echo -e "${YELLOW}### GET /resourceRoles/public${NC}"
                make_request "GET" "/resourceRoles/public" | jq .
                echo -e "${YELLOW}### GET /resourceRoles/public/1${NC}"
                make_request "GET" "/resourceRoles/public/1" | jq .
                TOKEN=$original_token # Restaurar token
                ;;
            4) break ;;
            *) echo -e "${RED}Opción no válida.${NC}" ;;
        esac
        press_enter_to_continue
    done
}

# --- Función de Login y Menú Principal ---

function iniciar_sesion() {
    echo -e "${BLUE}================== LOGIN Y CAPTURA DE TOKEN ==================${NC}"
    
    echo -e "${CYAN}(Escribe 'atras' para volver al menú principal)${NC}"
    read -p "Introduce el email del usuario: " USER_EMAIL
    if [[ "$USER_EMAIL" == "atras" ]]; then echo "Volviendo al menú principal..."; return; fi

    read -s -p "Introduce la contraseña: " USER_PASSWORD
    echo

    echo -e "${YELLOW}### Intentando iniciar sesión como $USER_EMAIL...${NC}"

    local login_response
    # Usamos -i para incluir encabezados y -w para obtener el código de estado al final
    login_response=$(curl -s -i -w "\nHTTP_STATUS_CODE:%{http_code}" -X POST "$BASE_URL/api/login" \
    -H "Content-Type: application/json" \
    -d "{
      \"email\": \"$USER_EMAIL\",
      \"password\": \"$USER_PASSWORD\"
    }")

    # Extraer el código de estado y el cuerpo de la respuesta
    local http_status_code=$(echo "$login_response" | grep "HTTP_STATUS_CODE" | cut -d':' -f2)
    local response_body=$(echo "$login_response" | sed -e 's/HTTP_STATUS_CODE:.*//g' | sed -e '1,/^\r$/d')

    if [ "$http_status_code" != "200" ]; then
        echo -e "${RED}❌ Error de autenticación. El servidor respondió con el código de estado: $http_status_code${NC}"
        echo "Respuesta del servidor:"
        # Si la respuesta es HTML (como en un error 404), jq fallará, así que la mostramos tal cual.
        if ! echo "$response_body" | jq . 2>/dev/null; then
            echo "$response_body"
        fi
        TOKEN=""
        return
    fi

    local temp_token=$(echo "$response_body" | jq -r '.token')
    if [ -z "$temp_token" ] || [ "$temp_token" == "null" ]; then
      echo -e "${RED}❌ Error: No se pudo obtener el token. Verifica las credenciales o el endpoint de login.${NC}"
      echo "Respuesta del servidor:"
      echo "$response_body" | jq .
      TOKEN=""
    else
      TOKEN=$temp_token
      echo -e "${GREEN}✅ Token capturado exitosamente.${NC}"
      
      # Decodificar el payload del JWT para obtener la fecha de expiración
      local jwt_payload=$(echo "$TOKEN" | cut -d'.' -f2)
      # Reemplazar caracteres URL-safe y añadir padding si es necesario
      jwt_payload=${jwt_payload//-/+}
      jwt_payload=${jwt_payload//_//}
      case $(( ${#jwt_payload} % 4 )) in
        2) jwt_payload+='==' ;;
        3) jwt_payload+='=' ;;
      esac
      
      local exp_timestamp=$(echo "$jwt_payload" | base64 -d 2>/dev/null | jq -r '.exp' 2>/dev/null)

      if [[ -n "$exp_timestamp" && "$exp_timestamp" =~ ^[0-9]+$ ]]; then
        TOKEN_EXPIRATION_TIME=$exp_timestamp
        local expiration_date=$(date -d "@$exp_timestamp" '+%Y-%m-%d %H:%M:%S')
        echo -e "${CYAN}El token expira a las: $expiration_date${NC}"
      else
        TOKEN_EXPIRATION_TIME=0 # No se pudo decodificar
      fi
    fi
}

function create_initial_admin() {
    echo -e "${BLUE}================== CREAR ADMINISTRADOR (SETUP INICIAL) ==================${NC}"
    echo -e "${YELLOW}Este proceso asignará el rol 'Administrator' a un usuario existente.${NC}"
    echo -e "${YELLOW}Asegúrate de haber creado al menos un usuario antes de continuar.${NC}"
    read -p "¿Deseas continuar? (s/n): " confirm
    if [[ "$confirm" != "s" ]]; then
        echo "Operación cancelada."
        return
    fi

    # Guardar el token actual y limpiarlo para usar los endpoints públicos
    local original_token=$TOKEN
    TOKEN=""

    # 1. Buscar el ID del rol "Administrator"
    echo -e "\n${CYAN}1. Buscando el rol 'Administrator'...${NC}"
    local roles_response=$(make_request "GET" "/roles/public")
    local role_id=$(echo "$roles_response" | jq -r '.roles[] | select(.name=="Administrator") | .id')

    if [[ -z "$role_id" || "$role_id" == "null" ]]; then
        echo -e "${RED}❌ Error: No se encontró el rol 'Administrator'.${NC}"
        echo -e "${YELLOW}Por favor, crea un rol con el nombre exacto 'Administrator' primero (Menú Gestión de Roles).${NC}"
        TOKEN=$original_token # Restaurar token
        return
    fi
    echo -e "${GREEN}✅ Rol 'Administrator' encontrado con ID: $role_id${NC}"

    # 2. Mostrar usuarios existentes y preguntar por el ID
    echo -e "\n${CYAN}2. Obteniendo lista de usuarios existentes...${NC}"
    # Para listar usuarios, necesitamos un token, así que restauramos el original temporalmente
    # si es que existía. Si no, la petición fallará, lo cual es esperado si no se ha iniciado sesión.
    local temp_token_holder=$TOKEN
    TOKEN=$original_token
    local users_response=$(make_request "GET" "/users")
    TOKEN=$temp_token_holder # Volvemos a limpiar el token para las llamadas públicas que siguen

    if ! echo "$users_response" | jq -e '.users | length > 0' > /dev/null 2>&1; then
        echo -e "${RED}❌ No se encontraron usuarios. Por favor, crea un usuario primero.${NC}"
        TOKEN=$original_token # Restaurar token
        return
    fi
    echo "$users_response" | jq .

    local admin_user_id
    read -p "Introduce el ID del usuario que quieres convertir en Administrador: " admin_user_id

    if ! [[ "$admin_user_id" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}❌ ID de usuario no válido. Debe ser un número.${NC}"
        TOKEN=$original_token # Restaurar token
        return
    fi
    echo -e "\n${CYAN}2. Asignando rol 'Administrator' al usuario con ID ${admin_user_id}...${NC}"
    local user_role_data=$(printf '{"role_id": %s, "user_id": %s, "is_active": "ACTIVE"}' "$role_id" "$admin_user_id")
    local user_role_response=$(make_request "POST" "/roleUsers/public" "$user_role_data")
    echo "$user_role_response" | jq .
    echo -e "${GREEN}✅ Asignación de rol a usuario completada.${NC}"

    # 3. Crear recursos básicos para la gestión
    echo -e "\n${CYAN}3. Asignando permisos básicos al rol 'Administrator'...${NC}"
    local resources_to_create=(
        '{"path": "/api/users", "method": "GET"}'
        '{"path": "/api/register", "method": "POST"}' # Corregido para usar el endpoint de registro
        '{"path": "/api/roles", "method": "GET"}'
        '{"path": "/api/roles", "method": "POST"}'
        '{"path": "/api/resources", "method": "GET"}'
        '{"path": "/api/resources", "method": "POST"}'
        '{"path": "/api/roleUsers", "method": "GET"}'
        '{"path": "/api/roleUsers", "method": "POST"}'
        '{"path": "/api/resourceRoles", "method": "GET"}'
        '{"path": "/api/resourceRoles", "method": "POST"}'
    )

    for resource_data in "${resources_to_create[@]}"; do
        local full_resource_data=$(echo "$resource_data" | jq '. + {"is_active": "ACTIVE"}')
        echo "Verificando/Creando recurso: $(echo $full_resource_data | jq -r '"\(.method) \(.path)"')"
        local resource_response=$(make_request "POST" "/resources/public" "$full_resource_data")
        local resource_id=$(echo "$resource_response" | jq -r '.id')

        if [[ -n "$resource_id" && "$resource_id" != "null" ]]; then
            echo -e "${CYAN}   Asignando recurso ID $resource_id al rol 'Administrator'...${NC}"
            local resource_role_data=$(printf '{"resource_id": %s, "role_id": %s, "is_active": "ACTIVE"}' "$resource_id" "$role_id")
            make_request "POST" "/resourceRoles/public" "$resource_role_data" > /dev/null
        fi
    done
    echo -e "${GREEN}✅ Recursos creados y asignados al rol 'Administrator'.${NC}"

    echo -e "\n${GREEN}🎉 ¡Setup del Administrador completado! Inicia sesión con el usuario (ID ${admin_user_id}) para empezar a gestionar la API.${NC}"
    TOKEN=$original_token # Restaurar token
}

function add_permission_to_admin_role() {
    echo -e "${BLUE}================== AÑADIR PERMISO A ROL ADMINISTRADOR ==================${NC}"
    
    # 1. Buscar el ID del rol "Administrator"
    echo -e "\n${CYAN}1. Buscando el rol 'Administrator'...${NC}"
    local roles_response=$(make_request "GET" "/roles")
    local admin_role_id=$(echo "$roles_response" | jq -r '.roles[] | select(.name=="Administrator") | .id')

    if [[ -z "$admin_role_id" || "$admin_role_id" == "null" ]]; then
        echo -e "${RED}❌ Error: No se encontró el rol 'Administrator'.${NC}"
        echo -e "${YELLOW}No se puede continuar. Asegúrate de que el rol exista.${NC}"
        return
    fi
    echo -e "${GREEN}✅ Rol 'Administrator' encontrado con ID: $admin_role_id${NC}"

    # 2. Pedir datos del nuevo recurso (endpoint)
    echo -e "\n${CYAN}2. Introduce los datos del nuevo endpoint a registrar y asignar.${NC}"
    read -p "Ruta del nuevo recurso (ej: /api/ventas): " path
    if [[ "$path" == "atras" ]]; then return; fi

    # Asegurarse de que la ruta comience con /api/
    if [[ ! "$path" == /api/* ]]; then
        path="/api$path"
    fi

    read -p "Método del recurso (GET, POST, PATCH, DELETE): " method
    if [[ "$method" == "atras" ]]; then return; fi

    # 3. Crear el nuevo recurso
    echo -e "\n${CYAN}3. Creando el nuevo recurso...${NC}"
    local resource_data=$(printf '{"path": "%s", "method": "%s", "is_active": "ACTIVE"}' "$path" "$method")
    local resource_response=$(make_request "POST" "/resources" "$resource_data")
    local new_resource_id=$(echo "$resource_response" | jq -r '.id')

    if [[ -z "$new_resource_id" || "$new_resource_id" == "null" ]]; then
        echo -e "${RED}❌ Error al crear el nuevo recurso.${NC}"
        echo "Respuesta del servidor:"
        echo "$resource_response" | jq .
        return
    fi
    echo -e "${GREEN}✅ Recurso '${method} ${path}' creado con ID: $new_resource_id${NC}"

    # 4. Asignar el nuevo recurso al rol de Administrador
    echo -e "\n${CYAN}4. Asignando el nuevo permiso al rol 'Administrator'...${NC}"
    local assignment_data=$(printf '{"resource_id": %s, "role_id": %s, "is_active": "ACTIVE"}' "$new_resource_id" "$admin_role_id")
    make_request "POST" "/resourceRoles" "$assignment_data" | jq .
    
    echo -e "\n${GREEN}🎉 ¡Permiso asignado exitosamente!${NC}"
}

function add_crud_permissions_to_admin() {
    echo -e "${BLUE}================== AÑADIR PERMISOS CRUD A ROL ADMINISTRADOR ==================${NC}"

    # 1. Buscar el ID del rol "Administrator"
    echo -e "\n${CYAN}1. Buscando el rol 'Administrator'...${NC}"
    local roles_response=$(make_request "GET" "/roles")
    local admin_role_id=$(echo "$roles_response" | jq -r '.roles[] | select(.name=="Administrator") | .id')

    if [[ -z "$admin_role_id" || "$admin_role_id" == "null" ]]; then
        echo -e "${RED}❌ Error: No se encontró el rol 'Administrator'.${NC}"
        return
    fi
    echo -e "${GREEN}✅ Rol 'Administrator' encontrado con ID: $admin_role_id${NC}"

    # 2. Pedir nombres de los modelos/recursos
    echo -e "\n${CYAN}2. Introduce los nombres de los nuevos modelos (separados por espacios).${NC}"
    read -p "Nombres (ej: clientes ventas productos): " resource_names
    if [[ -z "$resource_names" ]]; then
        echo "Operación cancelada."
        return
    fi

    # 3. Iterar sobre cada nombre y crear los 5 endpoints CRUD
    for resource_name in $resource_names; do
        echo -e "\n${YELLOW}--- Procesando modelo: '$resource_name' ---${NC}"
        
        # Definir los 5 endpoints CRUD estándar
        local crud_endpoints=(
            "GET /api/${resource_name}"
            "GET /api/${resource_name}/:id"
            "POST /api/${resource_name}"
            "PATCH /api/${resource_name}/:id"
            "DELETE /api/${resource_name}/:id"
            "DELETE /api/${resource_name}/:id/logic"
        )

        for endpoint in "${crud_endpoints[@]}"; do
            local method=$(echo "$endpoint" | cut -d' ' -f1)
            local path=$(echo "$endpoint" | cut -d' ' -f2)

            echo "Creando y asignando permiso para: ${method} ${path}"

            # Crear el recurso
            local resource_data=$(printf '{"path": "%s", "method": "%s", "is_active": "ACTIVE"}' "$path" "$method")
            local resource_response=$(make_request "POST" "/resources" "$resource_data")
            local new_resource_id=$(echo "$resource_response" | jq -r '.id')

            if [[ -z "$new_resource_id" || "$new_resource_id" == "null" ]]; then
                echo -e "${RED}   -> Error al crear el recurso. Saltando...${NC}"
                continue
            fi

            # Asignar el recurso al rol de Administrador
            local assignment_data=$(printf '{"resource_id": %s, "role_id": %s, "is_active": "ACTIVE"}' "$new_resource_id" "$admin_role_id")
            make_request "POST" "/resourceRoles" "$assignment_data" > /dev/null
        done
    done
    echo -e "\n${GREEN}🎉 ¡Todos los permisos CRUD han sido asignados exitosamente!${NC}"
}

function main_menu() {
    while true; do
        clear
        echo -e "\n${BLUE}=============== GESTOR DE API ===============${NC}"
        if [ -z "$TOKEN" ]; then
            echo -e "Estado: ${RED}No autenticado${NC}"
        else
            local current_time=$(date +%s)
            if [[ $TOKEN_EXPIRATION_TIME -gt $current_time ]]; then
                local time_left=$((TOKEN_EXPIRATION_TIME - current_time))
                local minutes=$((time_left / 60))
                local seconds=$((time_left % 60))
                echo -e "Estado: ${GREEN}Autenticado${NC} (expira en ${YELLOW}${minutes}m ${seconds}s${NC})"
            elif [[ $TOKEN_EXPIRATION_TIME -eq 0 ]]; then
                 echo -e "Estado: ${GREEN}Autenticado${NC} (expiración desconocida)"
            else
                echo -e "Estado: ${RED}Autenticado (TOKEN EXPIRADO)${NC}"
                TOKEN="" # Limpiar token expirado
            fi
        fi
        echo "-----------------------------------------------"
        echo "1. Iniciar Sesión (Obtener Token)"
        echo "2. Gestión de Usuarios"
        echo "3. Gestión de Roles"
        echo "4. Gestión de Recursos (Endpoints)"
        echo "5. Asignar Roles a Usuarios"
        echo "6. Asignar Permisos a Roles (Recurso-Rol)"
        echo "7. Crear Administrador (Setup Inicial)"
        echo "8. Añadir Permiso a Administrador"
        echo "9. Añadir Permisos CRUD a Admin"
        echo "10. Mostrar Token Actual"
        echo "11. Salir"
        echo -e "${BLUE}===============================================${NC}"
        read -p "Elige una opción: " main_choice

        # Validar si se requiere token para la opción elegida
        if [[ ("$main_choice" -ge 2 && "$main_choice" -le 9) && "$main_choice" -ne 7 && -z "$TOKEN" ]]; then
            echo -e "\n${RED}Error: Esta opción requiere que inicies sesión primero (Opción 1).${NC}"
            press_enter_to_continue
            continue
        fi

        case $main_choice in
            1) iniciar_sesion ;;
            2) user_menu ;;
            3) role_menu ;;
            4) resource_menu ;;
            5) role_user_menu ;;
            6) resource_role_menu ;;
            7) create_initial_admin ;;
            8) add_permission_to_admin_role ;;
            9) add_crud_permissions_to_admin ;;
            10) 
                if [ -z "$TOKEN" ]; then
                    echo -e "${YELLOW}No hay ningún token capturado.${NC}"
                else
                    echo -e "${GREEN}Token actual:${NC} $TOKEN"
                fi
                ;;
            11)
                echo "👋 Saliendo del script."
                exit 0
                ;;
            *)
                echo -e "${RED}Opción no válida. Inténtalo de nuevo.${NC}"
                ;;
        esac
        
        press_enter_to_continue
    done
}

# --- Inicio del Script ---

check_jq

echo -e "${GREEN}🚀 Iniciando Gestor de API para $BASE_URL${NC}"

main_menu
