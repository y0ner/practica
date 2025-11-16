#!/bin/bash

# ==========================================
# 2️⃣2️⃣ Actualizar src/config/index.ts con rutas
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

echo -e "${CYAN}Actualizando archivo src/config/index.ts con las rutas...${NC}"
mkdir -p src/config

ROUTES_DIR="src/routes"

if [ ! -d "$ROUTES_DIR" ]; then
    echo -e "${YELLOW}⚠️  El directorio de rutas '$ROUTES_DIR' no existe. Ejecuta primero los scripts de creación de rutas.${NC}"
    pause
    exit 1
fi

# --- Generar contenido dinámico ---
IMPORTS_BLOCK=""
ROUTES_INSTANCES_BLOCK=""

for route_file in $(find "$ROUTES_DIR" -type f -name "*.ts" ! -name "index.ts"); do
    # Obtener la ruta relativa desde 'src/routes'
    relative_path=${route_file#"$ROUTES_DIR/"}

    # Lógica para rutas de proyecto (ej: Client.Routes.ts)
    if [[ "$relative_path" == *.Routes.ts ]]; then
        ClassName=$(basename "$relative_path" .Routes.ts)
        ClassName="${ClassName}Routes"
        import_path="./$(tr '[:upper:]' '[:lower:]' <<< ${ClassName%Routes})"
    # Lógica para rutas de autorización (ej: authorization/user.ts)
    else
        path_without_ext=${relative_path%.ts}
        # Tomar solo el nombre del archivo, no la ruta, para el nombre de la clase
        ClassName=$(basename "$path_without_ext")
        ClassName=$(echo "$ClassName" | sed -r 's/(^|[_])(.)/\U\2/g' | sed 's/_//g')
        if [[ "$ClassName" != *Routes ]]; then
            ClassName="${ClassName}Routes"
        fi
        import_path="./$path_without_ext"
    fi
    
    variableName=$(echo ${ClassName:0:1} | tr '[:upper:]' '[:lower:]')
    variableName+=${ClassName:1}

    # Bloque de Imports para src/routes/index.ts
    IMPORTS_BLOCK+="import { ${ClassName} } from \"${import_path}\";\n"
    
    # Bloque de Instancias para src/config/index.ts
    ROUTES_INSTANCES_BLOCK+="    this.routePrv.${variableName}.routes(this.app);\n"
done


cat <<'EOF' > src/config/index.ts
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
    // Las rutas se inyectarán aquí dinámicamente
  }

  public async listen() {
    await this.app.listen(this.app.get('port'));
    console.log('Server on port', this.app.get('port'));
  }
EOF
echo -e "${GREEN}✅ Archivo src/config/index.ts actualizado correctamente.${NC}"

# Inyectar el bloque de rutas dinámicas en el archivo `src/routes/index.ts`
# Usamos sed para reemplazar el comentario marcador de posición con el bloque de rutas real.
sed -i "/\/\/ Las rutas se inyectarán aquí dinámicamente/c\\${ROUTES_INSTANCES_BLOCK}" src/config/index.ts

# Ahora, necesitamos actualizar el archivo `src/routes/index.ts` para que contenga las instancias
ROUTES_INDEX_FILE="src/routes/index.ts"

echo -e "${CYAN}Actualizando archivo src/routes/index.ts...${NC}"

cat <<EOF > "$ROUTES_INDEX_FILE"
$IMPORTS_BLOCK

export class Routes {
EOF

for route_file in $(find "$ROUTES_DIR" -type f -name "*.ts" ! -name "index.ts"); do
    relative_path=${route_file#"$ROUTES_DIR/"}

    if [[ "$relative_path" == *.Routes.ts ]]; then
        ClassName=$(basename "$relative_path" .Routes.ts)
        ClassName="${ClassName}Routes"
    else
        path_without_ext=${relative_path%.ts}
        # Tomar solo el nombre del archivo, no la ruta, para el nombre de la clase
        ClassName=$(basename "$path_without_ext")
        ClassName=$(echo "$ClassName" | sed -r 's/(^|[_])(.)/\U\2/g' | sed 's/_//g')
        if [[ "$ClassName" != *Routes ]]; then
            ClassName="${ClassName}Routes"
        fi
    fi

    variableName=$(echo ${ClassName:0:1} | tr '[:upper:]' '[:lower:]')
    variableName+=${ClassName:1}

    echo "  public ${variableName}: ${ClassName} = new ${ClassName}();" >> "$ROUTES_INDEX_FILE"
done


echo "}" >> "$ROUTES_INDEX_FILE"

echo -e "${GREEN}✅ Archivo src/routes/index.ts actualizado dinámicamente.${NC}"
pause