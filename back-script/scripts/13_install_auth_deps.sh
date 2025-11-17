#!/bin/bash

# ==========================================
# 1️⃣3️⃣ Instalar dependencias de autenticación
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Instalando dependencias de autenticación...${NC}"
npm install bcryptjs jsonwebtoken path-to-regexp
npm install -D @types/bcryptjs @types/jsonwebtoken
echo -e "${GREEN}✅ Dependencias de autenticación instaladas.${NC}"
pause