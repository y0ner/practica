#!/bin/bash

# ==========================================
# 6️⃣ Inicializar proyecto Node + TypeScript
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Inicializando proyecto Node.js con TypeScript...${NC}"

echo -e "${CYAN}🔍 Verificando si jq está instalado...${NC}"
if command -v jq >/dev/null 2>&1; then
  echo -e "${GREEN}✅ jq ya está instalado. Versión:${NC} $(jq --version)"
else
  echo -e "${YELLOW}jq no está instalado. Instalando...${NC}"
  sudo apt update -y && sudo apt install jq -y
  echo -e "${GREEN}✅ jq instalado correctamente.${NC}"
fi

npm init -y
npm install -D typescript @types/node nodemon ts-node
npm install -D @types/express @types/morgan @types/cors
npx tsc --init

cat <<EOF > tsconfig.json
{
  "compilerOptions": {
    "target": "es2016",
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",
    "esModuleInterop": true,
    "forceConsistentCasingInFileNames": true,
    "strict": true,
    "verbatimModuleSyntax": false,
    "skipLibCheck": true
  }
}
EOF

jq '.scripts = {"build": "tsc", "dev": "nodemon src/server.ts --exec ts-node"} | .type = "commonjs"' package.json > temp.json && mv temp.json package.json
echo -e "${GREEN}✅ Proyecto Node.js inicializado correctamente.${NC}"
pause