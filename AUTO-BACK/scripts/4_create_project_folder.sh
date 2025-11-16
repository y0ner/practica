#!/bin/bash

# ==========================================
# 4️⃣ Crear carpeta del proyecto
# Autor: Yoner
# ==========================================

# Cargar utilidades (colores)
. "$(dirname "$0")/utils.sh"

read -p "Nombre de la carpeta del proyecto: " folder

mkdir -p "../$folder"
sudo chmod -R 777 "../$folder"

echo -e "${GREEN}Carpeta '$folder' creada en el directorio superior y permisos aplicados.${NC}"

echo "$folder"