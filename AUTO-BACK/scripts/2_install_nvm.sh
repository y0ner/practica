#!/bin/bash

# ==========================================
# 2️⃣ Instalar / Verificar NVM
# Autor: Yoner
# ==========================================

# Cargar utilidades (colores y función de pausa)
. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}🔍 Verificando si NVM está instalado...${NC}"
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  echo -e "${GREEN}✅ NVM ya está instalado.${NC}"
  . "$NVM_DIR/nvm.sh" # Cargar NVM en la sesión actual del script
  nvm --version
else
  echo -e "${YELLOW}NVM no encontrado. Instalando...${NC}"
  wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.39.0/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" # Cargar NVM recién instalado
  echo -e "${GREEN}✅ NVM instalado correctamente. Versión:${NC} $(nvm --version)"
fi
pause