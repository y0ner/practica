#!/bin/bash

# ==========================================
# 🔟 Instalar dependencias de base de datos
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Instalando dependencias de base de datos...${NC}"
npm install sequelize mysql2 pg pg-hstore tedious oracledb
npm install -D @types/sequelize
echo -e "${GREEN}✅ Dependencias de base de datos instaladas.${NC}"
pause