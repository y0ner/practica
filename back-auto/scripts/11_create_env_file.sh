#!/bin/bash

# ==========================================
# 1️⃣1️⃣ Crear archivo .env
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Creando archivo .env...${NC}"

cat <<'EOF' > .env
PORT=4000

# Variable para seleccionar el motor de base de datos
DB_ENGINE=mysql

# Configuración para MySQL
MYSQL_HOST=localhost
MYSQL_USER=yoner
MYSQL_PASSWORD=yoner
MYSQL_NAME=prueba
MYSQL_PORT=3306
DB_TIMEZONE=America/Bogota

# Configuración para PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_NAME=almacen_2025_iisem_node
POSTGRES_PORT=5432

# Configuración para SQL Server
MSSQL_HOST=localhost
MSSQL_USER=sa
MSSQL_PASSWORD=password
MSSQL_NAME=almacen_2025_iisem_node
MSSQL_PORT=1433

# Configuración para Oracle
ORACLE_HOST=localhost
ORACLE_USER=ALMACENDB_ADMIN
ORACLE_PASSWORD=password
ORACLE_NAME=xe
ORACLE_PORT=1521

# JWT Secret
JWT_SECRET=your_jwt_secret_key_here
EOF

echo -e "${GREEN}✅ Archivo .env creado.${NC}"
pause