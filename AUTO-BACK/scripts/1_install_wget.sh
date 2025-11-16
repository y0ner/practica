#!/bin/bash

# ==========================================
# 1️⃣ Instalar / Verificar wget
# Autor: Yoner
# ==========================================

# Cargar utilidades (colores y función de pausa)
. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}🔍 Verificando si wget está instalado...${NC}"
if command -v wget >/dev/null 2>&1; then
  echo -e "${GREEN}✅ wget ya está instalado. Versión:${NC} $(wget --version | head -n 1)"
else
  echo -e "${YELLOW}wget no está instalado. Instalando...${NC}"
  sudo apt-get update -y && sudo apt-get install -y wget
  echo -e "${GREEN}✅ wget instalado correctamente.${NC}"
fi
pause