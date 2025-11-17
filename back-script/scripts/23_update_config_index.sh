#!/bin/bash

# Obtener el directorio absoluto del script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Cargar utilidades (colores)
. "$SCRIPT_DIR/utils.sh"

echo -e "${CYAN}=======================================================${NC}"
echo -e "${CYAN}🚀 Paso 23: Actualizando el archivo de configuración (src/config/index.ts)${NC}"
echo -e "${CYAN}=======================================================${NC}"

# Directorio del proyecto
PROJECT_DIR=$(pwd)
CONFIG_INDEX_PATH="$PROJECT_DIR/src/config/index.ts"
ROUTES_DIR="$PROJECT_DIR/src/routes"

if [ ! -d "$ROUTES_DIR" ]; then
    echo -e "${RED}❌ Error: El directorio de rutas 'src/routes' no existe.${NC}"
    echo -e "${RED}Asegúrate de haber ejecutado los pasos anteriores para crear las rutas.${NC}"
    exit 1
fi

# --- Generar contenido para las rutas dinámicas ---

DYNAMIC_ROUTES_CONFIG=""

# Buscar archivos .ts en src/routes, excluyendo index.ts y el directorio authorization
for file in $(find "$ROUTES_DIR" -maxdepth 1 -type f -name "*.ts" ! -name "index.ts"); do
    # Obtener el nombre base sin la extensión .ts (ej: client o Client.Routes)
    file_basename=$(basename "$file" .ts)

    # 1. Generar el nombre de la clase (ej: Client.Routes -> ClientRoutes)
    ClassName=$(echo "$file_basename" | sed 's/\.//g')

    # 2. Generar el nombre de la propiedad (ej: ClientRoutes -> clientRoutes)
    propName="$(tr '[:upper:]' '[:lower:]' <<< ${ClassName:0:1})${ClassName:1}"
	
    echo -e "${GREEN}🔎 Ruta encontrada: ${file_basename}.ts. Generando configuración...${NC}"

    # 3. Generar la llamada a la ruta
    # ej: this.routePrv.clientRoutes.routes(this.app);
    DYNAMIC_ROUTES_CONFIG+="    this.routePrv.${propName}.routes(this.app);"$'\n'
done

if [ -z "$DYNAMIC_ROUTES_CONFIG" ]; then
    echo -e "${YELLOW}⚠️ No se encontraron rutas de proyecto personalizadas en 'src/routes'. El archivo de configuración solo contendrá las rutas de autorización.${NC}"
fi

# --- Contenido estático del archivo de configuración ---

CONFIG_CONTENT=$(cat <<EOF
import dotenv from "dotenv";
import express, { Application } from "express";
import morgan from "morgan";
import { sequelize, testConnection, getDatabaseInfo } from "../database/db";
import { Routes } from "../routes/index";

var cors = require("cors");

dotenv.config();

export class App {
  public app: Application;
  public routePrv: Routes = new Routes();

  constructor(private port?: number | string) {
    this.app = express();
    this.settings();
    this.middlewares();
    this.routes();
    this.dbConnection();
  }

  private settings(): void {
    this.app.set('port', this.port || process.env.PORT || 4000);
  }

  private middlewares(): void {
    this.app.use(morgan('dev'));
    this.app.use(cors());
    this.app.use(express.json());
    this.app.use(express.urlencoded({ extended: false }));
  }

  // Route configuration
  private routes(): void {
${DYNAMIC_ROUTES_CONFIG}
    // --- Authorization Routes ---
    this.routePrv.userRoutes.routes(this.app);
    this.routePrv.roleRoutes.routes(this.app);
    this.routePrv.roleUserRoutes.routes(this.app);
    this.routePrv.refreshTokenRoutes.routes(this.app);
    this.routePrv.resourceRoutes.routes(this.app);
    this.routePrv.resourceRoleRoutes.routes(this.app);
    this.routePrv.authRoutes.routes(this.app);
  }

  private async dbConnection(): Promise<void> {
    try {
      const dbInfo = getDatabaseInfo();
      console.log(\`🔗 Intentando conectar a: \${dbInfo.engine.toUpperCase()}\`);
      const isConnected = await testConnection();
      if (!isConnected) {
        throw new Error(\`No se pudo conectar a la base de datos \${dbInfo.engine.toUpperCase()}\`);
      }
      await sequelize.sync({ force: false });
      // await sequelize.query('SET FOREIGN_KEY_CHECKS = 0;');
      // await sequelize.sync({ force: true });
      // await sequelize.query('SET FOREIGN_KEY_CHECKS = 1;');
      console.log(\`📦 Base de datos sincronizada exitosamente\`);
    } catch (error) {
      console.error("❌ Error al conectar con la base de datos:", error);
      process.exit(1);
    }
  }

  async listen() {
    await this.app.listen(this.app.get('port'));
    console.log(\`🚀 Servidor ejecutándose en puerto \${this.app.get('port')}\`);
  }
}
EOF
)

# --- Escribir el archivo final ---

echo "$CONFIG_CONTENT" > "$CONFIG_INDEX_PATH"

echo -e "\n${GREEN}✅ ¡Éxito! El archivo 'src/config/index.ts' ha sido generado/actualizado correctamente.${NC}"
echo -e "${YELLOW}-------------------------------------------------------${NC}"

# Preguntar si quiere ver el archivo
read -p "¿Deseas ver el contenido del archivo 'src/config/index.ts' actualizado? (s/n): " view_file
if [[ "$view_file" == "s" || "$view_file" == "S" ]]; then
    echo -e "${YELLOW}--- Contenido de src/config/index.ts ---${NC}"
    cat "$CONFIG_INDEX_PATH"
    echo -e "${YELLOW}----------------------------------------${NC}"
fi