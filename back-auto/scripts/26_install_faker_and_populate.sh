#!/bin/bash

# ==========================================
# 🚀 Paso 26: Instalar faker y crear script de población DINÁMICO
# Autor: Yoner
# ==========================================

# Obtener el directorio absoluto del script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Cargar utilidades (colores y pausa)
. "$SCRIPT_DIR/utils.sh"

echo -e "${CYAN}=======================================================${NC}"
echo -e "${CYAN}🚀 Paso 26: Instalando faker y creando script de población DINÁMICO${NC}"
echo -e "${CYAN}=======================================================${NC}"

# --- 1. Instalar dependencias ---
echo -e "${YELLOW}🔄 Instalando @faker-js/faker y ts-node...${NC}"
npm install @faker-js/faker ts-node > /dev/null 2>&1

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}jq no está instalado. Instalando...${NC}"
    sudo apt-get update -y && sudo apt-get install -y jq
fi

echo -e "${GREEN}✅ Dependencias instaladas correctamente.${NC}"

# --- 2. Definir rutas y encontrar modelos ---
PROJECT_DIR=$(pwd)
MODEL_DIR="$PROJECT_DIR/src/models"
FAKER_DIR="$PROJECT_DIR/src/faker"
POPULATE_SCRIPT_PATH="$FAKER_DIR/populate.ts"

mkdir -p "$FAKER_DIR"

if [ ! -d "$MODEL_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio de modelos 'src/models' no fue encontrado.${NC}"
    exit 1
fi

MODEL_FILES=$(find "$MODEL_DIR" -maxdepth 1 -type f -name "*.ts" ! -name "index.ts" ! -name "User.ts" ! -name "Role.ts" ! -name "RoleUser.ts" ! -name "Resource.ts" ! -name "ResourceRole.ts" ! -name "RefreshToken.ts")

if [ -z "$MODEL_FILES" ]; then
    echo -e "${YELLOW}⚠️ No se encontraron modelos de proyecto. No se generará el script de población.${NC}"
    pause
    exit 0
fi

# --- 3. Generar contenido dinámico del script ---

echo -e "${CYAN}⚙️  Generando script de población dinámico en '$POPULATE_SCRIPT_PATH'...${NC}"

DYNAMIC_IMPORTS=""
DYNAMIC_FUNCTIONS=""
FUNCTION_CALLS=""

# Función para generar una llamada a faker.js basada en el nombre del atributo
get_faker_call() {
    local attr=$1
    case $attr in
        *email*) echo "faker.internet.email()" ;;
        *password*) echo "faker.internet.password()" ;;
        *name*|*nombre*) echo "faker.person.fullName()" ;;
        *phone*|*telefono*) echo "faker.phone.number()" ;;
        *address*|*direccion*) echo "faker.location.streetAddress()" ;;
        *date*|*fecha*) echo "faker.date.past()" ;;
        *price*|*precio*|*total*|*subtotal*) echo "faker.number.int({ min: 10000, max: 500000 })" ;;
        *tax*|*discounts*) echo "faker.number.int({ min: 1000, max: 50000 })" ;;
        *description*|*descripcion*) echo "faker.lorem.sentence()" ;;
        *quantity*|*cantidad*) echo "faker.number.int({ min: 1, max: 100 })" ;;
        *brand*|*marca*) echo "faker.company.name()" ;;
        *stock*) echo "faker.number.int({ min: 1, max: 20 })" ;;
        *_id)
            # Extrae el nombre del modelo de la clave foránea (ej: client_id -> Client)
            local related_model_name=$(echo "$attr" | sed -e 's/_id$//' -e 's/\(.*\)/\u\1/')
            echo "'<FK_PLACEHOLDER>${related_model_name}'" # Placeholder para reemplazar después
            ;;
        *) echo "faker.lorem.word()" ;;
    esac
}

# Ordenar modelos: los que no tienen FKs primero
MODELS_WITH_FK=""
MODELS_WITHOUT_FK=""

for model_file in $MODEL_FILES; do
    # Si el archivo contiene "_id" Y NO contiene "hasMany" (para evitar falsos positivos en padres)
    if grep -q "_id" "$model_file" && ! grep -q "hasMany" "$model_file"; then
        MODELS_WITH_FK+="$model_file "
    else
        MODELS_WITHOUT_FK+="$model_file "
    fi
done
SORTED_MODEL_FILES="${MODELS_WITHOUT_FK}${MODELS_WITH_FK}"

for model_file in $SORTED_MODEL_FILES; do
    ModelName=$(basename "$model_file" .ts)
    modelNameLower=$(tr '[:upper:]' '[:lower:]' <<< "$ModelName")

    echo -e "${GREEN}   -> Procesando modelo: ${ModelName}${NC}"

    DYNAMIC_IMPORTS+="import { ${ModelName} } from '../models/${ModelName}';\n"
    
    # Generar los atributos para el objeto `create`
    attributes_body=""
    attributes=$(awk '/export interface .*I {/,/}/ {if ($0 !~ /{|}|export|status|id\?:/) {gsub(/:.*/, ""); gsub(/[?]/, ""); print $1}}' "$model_file")
    
    while IFS= read -r attr; do
        if [ -n "$attr" ]; then
            faker_call=$(get_faker_call "$attr")
            attributes_body+="            ${attr}: ${faker_call},\n"
        fi
    done <<< "$attributes"

    # Generar la función de población para este modelo
    # Primero, creamos la plantilla de la función
    function_template=$(cat <<EOF

async function populate${ModelName}s(count: number) {
    console.log('Populating ${ModelName}s...');
    const createdItems = [];
    for (let i = 0; i < count; i++) {
        const newItem = await ${ModelName}.create({
${attributes_body}            status: 'ACTIVE',
        });
        createdItems.push(newItem);
    }
    populatedIds['${ModelName}'] = createdItems;
}
EOF
)

    # Almacenamos los IDs de los modelos poblados para usarlos en las FKs
    FUNCTION_CALLS+="    await populate${ModelName}s(50);\n" # Se mantiene para el orden de llamada
    DYNAMIC_FUNCTIONS+="$function_template\n" # Se añade la función con placeholders
done

# --- 4. Ensamblar el script final ---

POPULATE_CONTENT=$(cat <<EOF
import { faker } from '@faker-js/faker';
import { sequelize } from '../database/db';
${DYNAMIC_IMPORTS}

// Contenedor para los IDs de los modelos poblados
const populatedIds: { [key: string]: any[] } = {};

async function main() {
    console.log('Syncing database...');
    await sequelize.sync({ force: true }); // ¡CUIDADO! Esto borrará todos los datos existentes.

    console.log('Starting data population...');
${FUNCTION_CALLS}
    console.log('Data population finished successfully.');
}
${DYNAMIC_FUNCTIONS}

main().catch(e => {
    console.error('Error populating database:', e);
    process.exit(1);
});

/*
  Para ejecutar este script y poblar la base de datos (esto borrará los datos existentes),
  asegúrate de que el script "populate" esté en tu package.json y luego ejecuta:
  npm run populate
*/
EOF
)

# Reemplazar los placeholders de FK en el script completo.
# Esto asegura que `populatedIds` esté definido antes de que se intente usar.
FINAL_SCRIPT=$(echo "$POPULATE_CONTENT" | sed -E "s/'<FK_PLACEHOLDER>([^']*)'/faker.helpers.arrayElement(populatedIds['\1']).id/g" | sed "s/createdItems.push(newItem);/createdItems.push(newItem as any);/g")

echo -e "$FINAL_SCRIPT" > "$POPULATE_SCRIPT_PATH"

# --- 5. Añadir script a package.json ---
echo -e "${CYAN}📦 Añadiendo script 'npm run populate' a package.json...${NC}"
if ! grep -q "populate" package.json; then
    jq '.scripts.populate = "ts-node src/faker/populate.ts"' package.json > package.json.tmp && mv package.json.tmp package.json
fi


echo -e "\n${GREEN}✅ ¡Éxito! Script de población dinámico creado en '${POPULATE_SCRIPT_PATH}'.${NC}"
echo -e "${YELLOW}👉 Para poblar tu base de datos (esto borrará los datos actuales), ejecuta:${NC}"
echo -e "${WHITE}   npm run populate${NC}"

pause