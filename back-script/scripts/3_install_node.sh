#!/bin/bash

# ==========================================
# 3️⃣ Instalar / Verificar Node.js (última LTS)
# Autor: Yoner
# ==========================================

# Cargar utilidades (colores y función de pausa)
. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}🔍 Verificando si Node.js está instalado...${NC}"

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
else
  echo -e "${YELLOW}⚠️  NVM no está instalado. Ejecuta primero la opción 2.${NC}"
  pause
  exit 1
fi

if command -v node >/dev/null 2>&1; then
  current_ver=$(node -v)
  echo -e "${GREEN}✅ Node.js ya está instalado. Versión:${NC} ${current_ver}"
  read -p "¿Deseas actualizar a la última versión LTS? (s/n): " resp
  if [[ $resp != "s" && $resp != "S" ]]; then
    pause
    exit 0
  fi
fi

latest_lts=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
echo -e "${CYAN}Descargando e instalando Node.js ${latest_lts}...${NC}"
nvm install "$latest_lts"
nvm alias default "$latest_lts"
nvm use default
echo -e "${GREEN}✅ Node.js instalado correctamente. Versión activa:${NC} $(node -v)"
pause