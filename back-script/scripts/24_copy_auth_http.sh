#!/bin/bash

# Obtener el directorio absoluto del script para que las rutas no se rompan
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Cargar utilidades (colores y pausa)
. "$SCRIPT_DIR/utils.sh"

echo -e "${CYAN}=======================================================${NC}"
echo -e "${CYAN}🚀 Paso 24: Copiando archivos HTTP de autorización (.http)${NC}"
echo -e "${CYAN}=======================================================${NC}"

# Directorio del proyecto (directorio de trabajo actual)
PROJECT_DIR=$(pwd)

# Directorio de recursos (un nivel arriba del directorio de scripts)
RECURSOS_DIR="$SCRIPT_DIR/../recursos"

# Rutas de origen y destino
SOURCE_DIR="$RECURSOS_DIR/http/authorization"
DEST_DIR="$PROJECT_DIR/src/http"

# 1. Verificar que el directorio de origen exista
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio de recursos '$SOURCE_DIR' no fue encontrado.${NC}"
    echo -e "${RED}Asegúrate de que la estructura del proyecto del asistente esté completa.${NC}"
    exit 1
fi

# 2. Verificar que el directorio de destino base exista (src/http)
if [ ! -d "$DEST_DIR" ]; then
    echo -e "${YELLOW}⚠️  El directorio de destino '$DEST_DIR' no existe. Creándolo ahora...${NC}"
    mkdir -p "$DEST_DIR"
fi

# 3. Copiar el directorio 'authorization' completo
echo -e "${GREEN}📂 Copiando '$SOURCE_DIR' a '$DEST_DIR'...${NC}"
cp -r "$SOURCE_DIR" "$DEST_DIR/"

if [ -d "$DEST_DIR/authorization" ]; then
    echo -e "\n${GREEN}✅ ¡Éxito! Los archivos .http de autorización han sido copiados a 'src/http/authorization'.${NC}"
    echo -e "${YELLOW}Puedes probarlos usando la extensión 'REST Client' en VSCode.${NC}"
else
    echo -e "\n${RED}❌ Error: Hubo un problema al copiar los archivos.${NC}"
    exit 1
fi

pause