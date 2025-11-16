#!/bin/bash

# ==========================================
# 0️⃣0️⃣ Seleccionar un proyecto existente
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Buscando proyectos en el directorio superior...${NC}" >&2

# Obtener una lista de directorios en la carpeta padre
mapfile -t projects < <(find ../ -maxdepth 1 -mindepth 1 -type d -printf '%f\n')

if [ ${#projects[@]} -eq 0 ]; then
    echo -e "${YELLOW}No se encontraron otros proyectos.${NC}" >&2
    exit 1
fi

echo -e "${YELLOW}Por favor, selecciona un proyecto para continuar:${NC}" >&2
select project in "${projects[@]}"; do
    if [ -n "$project" ]; then
        echo "$project" # Imprime el nombre del proyecto seleccionado para que main.sh lo capture
        exit 0
    else
        echo -e "${YELLOW}Selección inválida. Inténtalo de nuevo.${NC}" >&2
    fi
done