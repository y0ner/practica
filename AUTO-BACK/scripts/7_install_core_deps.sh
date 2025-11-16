#!/bin/bash

# ==========================================
# 7️⃣ Instalar dependencias core
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Instalando dependencias principales...${NC}"
npm install express cors morgan dotenv
echo -e "${GREEN}✅ Dependencias core instaladas.${NC}"
pause