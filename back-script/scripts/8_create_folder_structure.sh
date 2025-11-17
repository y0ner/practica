#!/bin/bash

# ==========================================
# 8️⃣ Crear estructura de carpetas
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Creando estructura de directorios...${NC}"
mkdir -p src/{config,controllers,database,faker,http,middleware,models,routes}
echo -e "${GREEN}✅ Estructura creada.${NC}"
pause