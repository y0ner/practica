#!/bin/bash

# ==========================================
# 1️⃣5️⃣ Copiar modelos de autorización
# Autor: Yoner
# ==========================================

# Obtener el directorio absoluto del script principal (un nivel arriba de este script)
MAIN_SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)

. "$MAIN_SCRIPT_DIR/scripts/utils.sh"

SOURCE_DIR="$MAIN_SCRIPT_DIR/recursos/models/authorization"
DEST_DIR="src/models"

echo -e "${CYAN}Copiando modelos de autorización desde '$SOURCE_DIR' a '$DEST_DIR'...${NC}"

if [ ! -d "$SOURCE_DIR" ]; then
  echo -e "${YELLOW}⚠️  El directorio de recursos no se encontró en la ruta esperada.${NC}"
  echo -e "${YELLOW}Asegúrate de que la carpeta 'recursos/models/authorization' exista.${NC}"
  pause
  exit 1
fi

mkdir -p "$DEST_DIR"
cp -r "$SOURCE_DIR" "$DEST_DIR/"

echo -e "${GREEN}✅ Modelos de autorización copiados correctamente.${NC}"
pause