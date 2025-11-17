#!/bin/bash

# Obtener el directorio absoluto del script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Cargar utilidades (colores y pausa)
. "$SCRIPT_DIR/utils.sh"

echo -e "${CYAN}=======================================================${NC}"
echo -e "${CYAN}🚀 Paso 25: Creando archivos .http para las rutas del proyecto${NC}"
echo -e "${CYAN}=======================================================${NC}"

# --- Funciones auxiliares ---

pluralize() {
    local word=$1
    # Si la palabra termina en 's', añade 'es', si no, solo 's'.
    if [[ "$word" =~ [sS]$ ]]; then
        echo "${word}es"
    else
        echo "${word}s"
    fi
}

# Función para generar valores de ejemplo basados en el nombre del atributo
generate_fake_value() {
    local attr_name=$1
    case $attr_name in
        *email*) echo "\"example@email.com\"" ;;
        *password*) echo "\"password123\"" ;;
        *name*|*nombre*) echo "\"John Doe\"" ;;
        *phone*|*telefono*) echo "\"3001234567\"" ;;
        *address*|*direccion*) echo "\"123 Main St\"" ;;
        *date*|*fecha*) echo "\"$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")\"" ;;
        *_id) echo 1 ;; # Para claves foráneas
        *) echo "\"valor de ejemplo\"" ;; # Valor por defecto
    esac
}
# Directorio del proyecto (directorio de trabajo actual)
PROJECT_DIR=$(pwd)

# Rutas de origen y destino
MODEL_DIR="$PROJECT_DIR/src/models"
DEST_DIR="$PROJECT_DIR/src/http"

# 1. Verificar que el directorio de modelos exista
if [ ! -d "$MODEL_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio de modelos 'src/models' no fue encontrado.${NC}"
    echo -e "${RED}Asegúrate de haber ejecutado el paso 16 para crear los modelos.${NC}"
    exit 1
fi

# 2. Crear el directorio de destino si no existe
mkdir -p "$DEST_DIR"

# 3. Iterar sobre los modelos del proyecto (excluyendo los de autorización)
MODEL_FILES=$(find "$MODEL_DIR" -maxdepth 1 -type f -name "*.ts" ! -name "index.ts" ! -name "User.ts" ! -name "Role.ts" ! -name "RoleUser.ts" ! -name "Resource.ts" ! -name "ResourceRole.ts" ! -name "RefreshToken.ts")

if [ -z "$MODEL_FILES" ]; then
    echo -e "${YELLOW}⚠️ No se encontraron modelos de proyecto en 'src/models'. No se generarán archivos .http.${NC}"
    pause
    exit 0
fi

for model_file in $MODEL_FILES; do
    # Extraer el nombre del modelo del nombre del archivo (ej: Client.ts -> Client)
    ModelName=$(basename "$model_file" .ts)
    
    # Convertir a minúsculas para la ruta (ej: Client -> client)
    modelNameLower=$(tr '[:upper:]' '[:lower:]' <<< "$ModelName")
    
    # Pluralizar para la ruta de la API (ej: client -> clients)
    modelNamePlural=$(pluralize "$modelNameLower")

    echo -e "${GREEN}🔎 Procesando modelo '$ModelName'. Generando archivo '$DEST_DIR/${ModelName}.http'...${NC}"

    # --- Extraer atributos del modelo para el cuerpo JSON ---
    json_body=""
    json_body_update=""
    # Usamos awk para leer la interfaz del modelo y extraer los nombres de los atributos
    attributes=$(awk '/export interface .*I {/,/}/ {if ($0 !~ /{|}|id|status/) {gsub(/:.*/, ""); gsub(/[?]/, ""); print $1}}' "$model_file")
    
    first_attr=true
    while IFS= read -r attr; do
        if [ -n "$attr" ]; then
            fake_value=$(generate_fake_value "$attr")

            # Añadir coma si no es el primer atributo
            if [ "$first_attr" = false ]; then
                json_body+=","$'\n'
                json_body_update+=","$'\n'
            fi

            # Añadir atributo con un valor de ejemplo
            json_body+="    \"$attr\": $fake_value"
            json_body_update+="    \"$attr\": $fake_value" # Usamos los mismos para el update

            first_attr=false
        fi
    done <<< "$attributes"

    # Añadir el campo status al final del body
    if [ "$first_attr" = false ]; then
        json_body+=","$'\n'
        json_body_update+=","$'\n'
    fi
    json_body+="    \"status\": \"ACTIVE\""
    json_body_update+="    \"status\": \"ACTIVE\""

    # Para el PATCH, a menudo solo se actualiza un campo, así que preparamos un ejemplo más simple
    patch_body="  \"name\": \"Nombre Actualizado\""

    # --- Generar el contenido del archivo .http ---
    HTTP_CONTENT=$(cat <<EOF
###
# @name ${ModelName}
# Variables de entorno para las pruebas de ${ModelName}
# @token = ey... (Pega aquí tu token JWT)
@baseUrl = http://localhost:4000

### ================== RUTAS SIN AUTENTICACIÓN ==================

### Obtener todos los ${modelNamePlural} (SIN token)
GET {{baseUrl}}/api/${modelNamePlural}/public

### Obtener ${ModelName} por ID (SIN token)
GET {{baseUrl}}/api/${modelNamePlural}/public/1

### Crear un nuevo ${ModelName} (SIN token)
POST {{baseUrl}}/api/${modelNamePlural}/public
Content-Type: application/json

{
${json_body}
}

### Actualizar un ${ModelName} (SIN token)
PATCH {{baseUrl}}/api/${modelNamePlural}/public/1
Content-Type: application/json

{
${patch_body}
}

### Eliminar un ${ModelName} físicamente (SIN token)
DELETE {{baseUrl}}/api/${modelNamePlural}/public/1

### Eliminar un ${ModelName} lógicamente (SIN token)
DELETE {{baseUrl}}/api/${modelNamePlural}/public/2/logic

### ================== RUTAS CON AUTENTICACIÓN ==================

### Obtener todos los ${modelNamePlural} (CON token)
GET {{baseUrl}}/api/${modelNamePlural}
Content-Type: application/json
Authorization: Bearer {{token}}

### Obtener un ${ModelName} por ID (CON token)
GET {{baseUrl}}/api/${modelNamePlural}/1
Content-Type: application/json
Authorization: Bearer {{token}}

### Crear un nuevo ${ModelName} (CON token)
POST {{baseUrl}}/api/${modelNamePlural}
Content-Type: application/json
Authorization: Bearer {{token}}

{
${json_body}
}

### Actualizar un ${ModelName} existente (CON token)
PATCH {{baseUrl}}/api/${modelNamePlural}/1
Content-Type: application/json
Authorization: Bearer {{token}}

{
${patch_body}
}

### Eliminar un ${ModelName} físicamente (CON token)
DELETE {{baseUrl}}/api/${modelNamePlural}/1
Authorization: Bearer {{token}}

### Borrado lógico de un ${ModelName} (CON token)
DELETE {{baseUrl}}/api/${modelNamePlural}/1/logic
Content-Type: application/json
Authorization: Bearer {{token}}

EOF
)

    # Escribir el contenido en el archivo .http
    # Usamos el nombre del modelo en minúsculas para el archivo, como en los ejemplos
    echo "$HTTP_CONTENT" > "$DEST_DIR/${modelNameLower}.http"
done

echo -e "\n${GREEN}✅ ¡Éxito! Se han generado los archivos .http en la carpeta 'src/http'.${NC}"
echo -e "${YELLOW}Recuerda reemplazar el token de ejemplo y ajustar los 'valores de ejemplo' en los archivos generados.${NC}"

pause