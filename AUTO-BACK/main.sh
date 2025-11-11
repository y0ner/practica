#!/bin/bash

# ==========================================
# 🚀 Asistente Interactivo de Proyecto Node.js (WSL)
# Autor: Yoner
# ==========================================

# Colores
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sin color

function pause() {
  read -p "Presiona [Enter] para continuar..."
}

# ==========================
# 1️⃣ Instalar / Verificar wget
# ==========================
function instalar_wget() {
  echo -e "${CYAN}🔍 Verificando si wget está instalado...${NC}"
  if command -v wget >/dev/null 2>&1; then
    echo -e "${GREEN}✅ wget ya está instalado. Versión:${NC} $(wget --version | head -n 1)"
  else
    echo -e "${YELLOW}wget no está instalado. Instalando...${NC}"
    sudo apt-get update -y && sudo apt-get install -y wget
    echo -e "${GREEN}✅ wget instalado correctamente.${NC}"
  fi
  pause
}

# ==========================
# 2️⃣ Instalar / Verificar NVM
# ==========================
function instalar_nvm() {
  echo -e "${CYAN}🔍 Verificando si NVM está instalado...${NC}"
  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    echo -e "${GREEN}✅ NVM ya está instalado.${NC}"
    . "$NVM_DIR/nvm.sh"
    nvm --version
  else
    echo -e "${YELLOW}NVM no encontrado. Instalando...${NC}"
    wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    echo -e "${GREEN}✅ NVM instalado correctamente. Versión:${NC} $(nvm --version)"
  fi
  pause
}

# ==========================
# 3️⃣ Instalar / Verificar Node.js (última LTS)
# ==========================
function instalar_node() {
  echo -e "${CYAN}🔍 Verificando si Node.js está instalado...${NC}"

  export NVM_DIR="$HOME/.nvm"
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
  else
    echo -e "${YELLOW}⚠️  NVM no está instalado. Ejecuta primero la opción 2.${NC}"
    pause
    return
  fi

  if command -v node >/dev/null 2>&1; then
    current_ver=$(node -v)
    echo -e "${GREEN}✅ Node.js ya está instalado. Versión:${NC} ${current_ver}"
    read -p "¿Deseas actualizar a la última versión LTS? (s/n): " resp
    if [[ $resp != "s" && $resp != "S" ]]; then
      pause
      return
    fi
  fi

  latest_lts=$(nvm ls-remote --lts | tail -1 | awk '{print $1}')
  echo -e "${CYAN}Descargando e instalando Node.js ${latest_lts}...${NC}"
  nvm install "$latest_lts"
  nvm alias default "$latest_lts"
  nvm use default
  echo -e "${GREEN}✅ Node.js instalado correctamente. Versión activa:${NC} $(node -v)"
  pause
}

# ==========================
# 4️⃣ Crear carpeta del proyecto
# ==========================
function crear_carpeta_proyecto() {
  read -p "Nombre de la carpeta del proyecto: " folder
  mkdir -p "$folder"
  sudo chmod -R 777 "$folder"
  cd "$folder" || exit
  echo -e "${GREEN}Carpeta '$folder' creada y permisos aplicados.${NC}"
  pause
}

# ==========================
# 5️⃣ Abrir Visual Studio Code
# ==========================
function iniciar_vscode() {
  echo -e "${CYAN}Abriendo Visual Studio Code...${NC}"
  code .
  pause
}

# ==========================
# 6️⃣ Inicializar proyecto Node + TypeScript
# ==========================
function iniciar_proyecto_node() {
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
}

# ==========================
# 7️⃣ Instalar dependencias core
# ==========================
function instalar_dependencias_core() {
  echo -e "${CYAN}Instalando dependencias principales...${NC}"
  npm install express cors morgan dotenv
  echo -e "${GREEN}✅ Dependencias core instaladas.${NC}"
  pause
}

# ==========================
# 8️⃣ Crear estructura de carpetas
# ==========================
function crear_estructura_directorios() {
  echo -e "${CYAN}Creando estructura de directorios...${NC}"
  mkdir -p src/{config,controllers,database,faker,http,middleware,models,routes}
  echo -e "${GREEN}✅ Estructura creada.${NC}"
  pause
}

# ==========================
# 9️⃣ Crear archivos base
# ==========================
function crear_archivos_base() {
  echo -e "${CYAN}Creando archivos base (server.ts / config/index.ts)...${NC}"

  mkdir -p src/config

  cat <<'EOF' > src/server.ts
import { App } from "./config/index";

async function main() {
  const app = new App();
  await app.listen();
}

main();
EOF

  cat <<'EOF' > src/config/index.ts
import dotenv from "dotenv";
import express, { Application } from "express";
import morgan from "morgan";
import { sequelize, testConnection, getDatabaseInfo } from "../database/db";
var cors = require("cors");

dotenv.config();

export class App {
  public app: Application;

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

  private routes(): void {
    // Las rutas se configurarán más adelante
  }

  private async dbConnection(): Promise<void> {
    try {
      // Mostrar información de la base de datos seleccionada
      const dbInfo = getDatabaseInfo();
      console.log(`🔗 Intentando conectar a: ${dbInfo.engine.toUpperCase()}`);

      // Probar la conexión
      const isConnected = await testConnection();

      if (!isConnected) {
        throw new Error(`No se pudo conectar a la base de datos ${dbInfo.engine.toUpperCase()}`);
      }

      // Sincronizar la base de datos
      await sequelize.sync({ force: false });
      console.log(`📦 Base de datos sincronizada exitosamente`);

    } catch (error) {
      console.error("❌ Error al conectar con la base de datos:", error);
      process.exit(1); // Terminar la aplicación si no se puede conectar
    }
  }

  async listen() {
    await this.app.listen(this.app.get('port'));
    console.log(`🚀 Servidor ejecutándose en puerto ${this.app.get('port')}`);
  }
}
EOF

  echo -e "${GREEN}✅ Archivos base creados correctamente.${NC}"
  pause
}

# ==========================
# 🔟 Instalar dependencias de base de datos
# ==========================
function instalar_dependencias_db() {
  echo -e "${CYAN}Instalando dependencias de base de datos...${NC}"
  npm install sequelize mysql2 pg pg-hstore tedious oracledb
  npm install -D @types/sequelize
  echo -e "${GREEN}✅ Dependencias de base de datos instaladas.${NC}"
  pause
}

# ==========================
# 1️⃣1️⃣ Crear archivo .env
# ==========================
function crear_archivo_env() {
  echo -e "${CYAN}Creando archivo .env...${NC}"

  cat <<EOF > .env
PORT=3000
DB_ENGINE=mysql
MYSQL_HOST=localhost
MYSQL_USER=admin
MYSQL_PASSWORD=password
MYSQL_NAME=almacen_2025_iisem_node
MYSQL_PORT=3306
POSTGRES_HOST=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_NAME=almacen_2025_iisem_node
POSTGRES_PORT=5432
MSSQL_HOST=localhost
MSSQL_USER=sa
MSSQL_PASSWORD=password
MSSQL_NAME=almacen_2025_iisem_node
MSSQL_PORT=1433
ORACLE_HOST=localhost
ORACLE_USER=ALMACENDB_ADMIN
ORACLE_PASSWORD=password
ORACLE_NAME=xe
ORACLE_PORT=1521
JWT_SECRET=your_jwt_secret_key_here
EOF

  echo -e "${GREEN}✅ Archivo .env creado.${NC}"
  pause
}

# ==========================
# 1️⃣2️⃣ Crear configuración de base de datos
# ==========================
function crear_config_db() {
  echo -e "${CYAN}Creando configuración de base de datos...${NC}"
  mkdir -p src/database

  cat <<'EOF' > src/database/db.ts
import { Sequelize } from "sequelize";
import dotenv from "dotenv";

dotenv.config();

interface DatabaseConfig {
  dialect: string;
  host: string;
  username: string;
  password: string;
  database: string;
  port: number;
}

const dbConfigurations: Record<string, DatabaseConfig> = {
  mysql: {
    dialect: "mysql",
    host: process.env.MYSQL_HOST || "localhost",
    username: process.env.MYSQL_USER || "root",
    password: process.env.MYSQL_PASSWORD || "",
    database: process.env.MYSQL_NAME || "test",
    port: parseInt(process.env.MYSQL_PORT || "3306")
  },
  postgres: {
    dialect: "postgres",
    host: process.env.POSTGRES_HOST || "localhost",
    username: process.env.POSTGRES_USER || "postgres",
    password: process.env.POSTGRES_PASSWORD || "",
    database: process.env.POSTGRES_NAME || "test",
    port: parseInt(process.env.POSTGRES_PORT || "5432")
  }
};

const selectedEngine = process.env.DB_ENGINE || "mysql";
const selectedConfig = dbConfigurations[selectedEngine];

if (!selectedConfig) {
  throw new Error(`Motor de base de datos no soportado: ${selectedEngine}`);
}

console.log(`🔌 Conectando a base de datos: ${selectedEngine.toUpperCase()}`);

export const sequelize = new Sequelize(
  selectedConfig.database,
  selectedConfig.username,
  selectedConfig.password,
  {
    host: selectedConfig.host,
    port: selectedConfig.port,
    dialect: selectedConfig.dialect as any,
    logging: process.env.NODE_ENV === "development" ? console.log : false,
    pool: { max: 5, min: 0, acquire: 30000, idle: 10000 }
  }
);

export const getDatabaseInfo = () => ({
  engine: selectedEngine,
  config: selectedConfig,
  connectionString: `${selectedConfig.dialect}://${selectedConfig.username}@${selectedConfig.host}:${selectedConfig.port}/${selectedConfig.database}`
});

export const testConnection = async (): Promise<boolean> => {
  try {
    await sequelize.authenticate();
    console.log(`✅ Conexión exitosa a ${selectedEngine.toUpperCase()}`);
    return true;
  } catch (error) {
    console.error(`❌ Error de conexión:`, error);
    return false;
  }
};
EOF

  echo -e "${GREEN}✅ Configuración de base de datos creada.${NC}"
  pause
}

# ==========================
# 1️⃣3️⃣ Instalar dependencias de autenticación
# ==========================
function instalar_dependencias_auth() {
  echo -e "${CYAN}Instalando dependencias de autenticación...${NC}"
  npm install bcryptjs jsonwebtoken path-to-regexp
  npm install -D @types/bcryptjs @types/jsonwebtoken
  echo -e "${GREEN}✅ Dependencias de autenticación instaladas.${NC}"
  pause
}

# ==========================
# 1️⃣4️⃣ Ejecutar servidor
# ==========================
function ejecutar_servidor() {
  echo -e "${CYAN}Ejecutando servidor...${NC}"
  npm run dev
}

# ==========================
# 2️⃣1️⃣ Crear src/routes/index.ts
# ==========================
function crear_routes_index() {
  echo -e "${CYAN}Creando archivo src/routes/index.ts...${NC}"
  mkdir -p src/routes
  cat <<'EOF' > src/routes/index.ts
import { Router } from "express";
import { ClientRoutes } from "./client";
import { SaleRoutes } from "./sale";
import { ProductRoutes } from "./product";
import { ProductTypeRoutes } from "./productType";
import { ProductSaleRoutes } from "./productSale";
import { UserRoutes } from "./authorization/user";
import { RoleRoutes } from "./authorization/role";
import { RoleUserRoutes } from "./authorization/role_user";
import { RefreshTokenRoutes } from "./authorization/refresk_token";
import { ResourceRoutes } from "./authorization/resource"; // Import ResourceRoutes
import { ResourceRoleRoutes } from "./authorization/resourceRole"; // Import ResourceRoleRoutes
import { AuthRoutes } from "./authorization/auth"; // Add this import

export class Routes {
  public clientRoutes: ClientRoutes = new ClientRoutes();
  public saleRoutes: SaleRoutes = new SaleRoutes();
  public productRoutes: ProductRoutes = new ProductRoutes();
  public productTypeRoutes: ProductTypeRoutes = new ProductTypeRoutes();
  public productSaleRoutes: ProductSaleRoutes = new ProductSaleRoutes();
  public userRoutes: UserRoutes = new UserRoutes();
  public roleRoutes: RoleRoutes = new RoleRoutes();
  public roleUserRoutes: RoleUserRoutes = new RoleUserRoutes();
  public refreshTokenRoutes: RefreshTokenRoutes = new RefreshTokenRoutes();
  public resourceRoutes: ResourceRoutes = new ResourceRoutes(); // Add ResourceRoutes
  public resourceRoleRoutes: ResourceRoleRoutes = new ResourceRoleRoutes(); // Add ResourceRoutes
  public authRoutes: AuthRoutes = new AuthRoutes(); // Add this line
}
EOF
  echo -e "${GREEN}✅ Archivo src/routes/index.ts creado correctamente.${NC}"
  pause
}

# ==========================
# 2️⃣2️⃣ Actualizar src/config/index.ts con rutas
# ==========================
function actualizar_config_index_con_rutas() {
  echo -e "${CYAN}Actualizando archivo src/config/index.ts con las rutas...${NC}"
  mkdir -p src/config

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
    this.routePrv.clientRoutes.routes(this.app);
    this.routePrv.saleRoutes.routes(this.app);
    this.routePrv.productRoutes.routes(this.app);
    this.routePrv.productTypeRoutes.routes(this.app);
    this.routePrv.productSaleRoutes.routes(this.app);
    this.routePrv.userRoutes.routes(this.app);
    this.routePrv.roleRoutes.routes(this.app);
    this.routePrv.roleUserRoutes.routes(this.app);
    this.routePrv.refreshTokenRoutes.routes(this.app);
    this.routePrv.resourceRoutes.routes(this.app);
    this.routePrv.resourceRoleRoutes.routes(this.app);
  }
EOF
  echo -e "${GREEN}✅ Archivo src/config/index.ts actualizado correctamente.${NC}"
  pause
}

# ==========================
# 2️⃣6️⃣ Instalar faker y crear script de población
# ==========================
function instalar_faker_y_crear_script() {
  echo -e "${CYAN}Instalando @faker-js/faker...${NC}"
  npm install @faker-js/faker
  echo -e "${GREEN}✅ @faker-js/faker instalado correctamente.${NC}"

  echo -e "${CYAN}Creando script de población de datos en src/faker/populate_data.ts...${NC}"
  mkdir -p src/faker

  cat <<'EOF' > src/faker/populate_data.ts
import { Client } from '../models/Client';
import { ProductType } from '../models/ProductType';
import { Product } from '../models/Product';
import { Sale } from '../models/Sale';
import { ProductSale } from '../models/ProductSale';
import { faker } from '@faker-js/faker';

async function createFakeData() {
    // Crear clientes falsos
    for (let i = 0; i < 50; i++) {
        await Client.create({
            name: faker.person.fullName(),
            address: faker.location.streetAddress(),
            phone: faker.phone.number(), // Genera un número de teléfono aleatorio
            email: faker.internet.email(),
            password: faker.internet.password(),
            status: 'ACTIVE',
        });
    }

    // Crear tipos de productos falsos
    for (let i = 0; i < 10; i++) {
        await ProductType.create({
            name: faker.commerce.department(),
            description: faker.commerce.productDescription(),
            status: 'ACTIVE',
        });
    }

    // Crear productos falsos
    const typeProducts = await ProductType.findAll();
    for (let i = 0; i < 20; i++) {
        await Product.create({
            name: faker.commerce.productName(),
            brand: faker.company.name(),
            price: faker.number.bigInt(),
            min_stock: faker.number.int({ min: 1, max: 10 }),
            quantity: faker.number.int({ min: 1, max: 100 }),
            product_type_id: typeProducts.length > 0
                ? typeProducts[faker.number.int({ min: 0, max: typeProducts.length - 1 })]?.id
                : null,
            status: 'ACTIVE',
        });
    }

    // Crear ventas falsas
    const clients = await Client.findAll();
    for (let i = 0; i < 100; i++) {
        await Sale.create({
            sale_date: faker.date.past(),
            subtotal: faker.number.bigInt(),
            tax: faker.number.bigInt(),
            discounts: faker.number.bigInt(),
            total: faker.number.bigInt(),
            status: 'ACTIVE',
            client_id: clients.length > 0
                ? clients[faker.number.int({ min: 0, max: clients.length - 1 })]?.id ?? null
                : null
        });
    }

//     // Crear productos ventas falsos
    const sales = await Sale.findAll();
    const products = await Product.findAll();
    for (let i = 0; i < 200; i++) {
        await ProductSale.create({
            total: faker.number.bigInt(),
            sale_id: sales[faker.number.int({ min: 0, max: sales.length - 1 })]?.id ?? null,
            product_id: products[faker.number.int({ min: 0, max: products.length - 1 })]?.id ?? null
        });
    }
}

createFakeData().then(() => {
    console.log('Datos falsos creados exitosamente');
}).catch((error) => {
    console.error('Error al crear datos falsos:', error);
});

// Para ejecutar este script, ejecute el siguiente comando:
// npm install -g ts-node
// ts-node src/faker/populate_data.ts
// npm install @faker-js/faker
EOF

  echo -e "${GREEN}✅ Script de población de datos creado correctamente.${NC}"
  pause
}

# ==========================
# 2️⃣7️⃣ Actualizar src/config/index.ts (final)
# ==========================
function actualizar_config_index_final() {
  echo -e "${CYAN}Actualizando archivo src/config/index.ts con la configuración final...${NC}"
  mkdir -p src/config # Asegurarse de que el directorio exista

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
    this.routePrv.clientRoutes.routes(this.app);
    this.routePrv.saleRoutes.routes(this.app);
    this.routePrv.productRoutes.routes(this.app);
    this.routePrv.productTypeRoutes.routes(this.app);
    this.routePrv.productSaleRoutes.routes(this.app);
    this.routePrv.userRoutes.routes(this.app);
    this.routePrv.roleRoutes.routes(this.app);
    this.routePrv.roleUserRoutes.routes(this.app);
    this.routePrv.refreshTokenRoutes.routes(this.app);
    this.routePrv.resourceRoutes.routes(this.app);
    this.routePrv.resourceRoleRoutes.routes(this.app);
    this.routePrv.authRoutes.routes(this.app)
  }

  private async dbConnection(): Promise<void> {
    try {
      const dbInfo = getDatabaseInfo();
      console.log(`🔗 Intentando conectar a: ${dbInfo.engine.toUpperCase()}`);
      const isConnected = await testConnection();
      if (!isConnected) { throw new Error(`No se pudo conectar a la base de datos ${dbInfo.engine.toUpperCase()}`); }
      await sequelize.sync({ force: false });
      console.log(`📦 Base de datos sincronizada exitosamente`);
    } catch (error) { console.error("❌ Error al conectar con la base de datos:", error); process.exit(1); }
  }

  async listen() { await this.app.listen(this.app.get('port')); console.log(`🚀 Servidor ejecutándose en puerto ${this.app.get('port')}`); }
}
EOF
  echo -e "${GREEN}✅ Archivo src/config/index.ts actualizado correctamente con la configuración final.${NC}"
  pause
}

# ==========================
# 2️⃣8️⃣ Crear src/middleware/auth.ts
# ==========================
function crear_middleware_auth() {
  echo -e "${CYAN}Creando archivo de middleware de autenticación en src/middleware/auth.ts...${NC}"
  mkdir -p src/middleware

  cat <<'EOF' > src/middleware/auth.ts
import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/authorization/User';
import { Role } from '../models/authorization/Role';
import { ResourceRole } from '../models/authorization/ResourceRole';
import { Resource } from '../models/authorization/Resource';
import { RoleUser } from '../models/authorization/RoleUser';
import { pathToRegexp } from 'path-to-regexp'; // Importar path-to-regexp
import { addEmitHelper } from 'typescript';


export const authMiddleware = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  const token = req.header('Authorization')?.replace('Bearer ', '');
  const currentRoute = req.originalUrl;
  const currentMethod = req.method;

  if (!token) {
    res.status(401).json({ error: 'Acceso denegado: No se proporcionó el token principal.' });
    return;
  }

  try {
    // Verificar si el token principal es válido
    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret') as jwt.JwtPayload;

    // Buscar el usuario en la base de datos
    const user: User | null = await User.findOne({ where: { id: decoded.id, is_active: 'ACTIVE' } });
    if (!user) {
      res.status(401).json({ error: 'Usuario no encontrado o inactivo.' });
      return;
    }

    // Validar autorización
    const isAuthorized = await validateAuthorization(decoded.id, currentRoute, currentMethod);
    if (!isAuthorized) {
      res.status(403).json({ error: 'No está autorizado para ejecutar esta petición.' });
      return;
    }

    // Continuar con la solicitud
    next();
  } catch (error: any) {
    if (error.name === 'TokenExpiredError') {
      res.status(401).json({ error: 'El token principal ha expirado.' });
    } else if (error.name === 'JsonWebTokenError') {
      res.status(401).json({ error: 'Token inválido.' });
    } else {
      res.status(500).json({ error: 'Error interno del servidor.', details: error.message });
    }
  }
};

export const validateAuthorization = async (userId: number, resourcePath: string, resourceMethod: string): Promise<boolean> => {
  try {
    // Obtener todos los recursos activos que coincidan con el método
    const resources = await Resource.findAll({
      where: { method: resourceMethod, is_active: "ACTIVE" },
    });

    // Convertir las rutas dinámicas a expresiones regulares y buscar coincidencias
    const matchingResource = resources.find((resource) => {
      const regex = pathToRegexp(resource.path).regexp.test(resourcePath);
      return regex;
    });

    if (!matchingResource) {
      return false; // No hay coincidencias para la ruta y el método
    }

    // Verificar si existe una relación válida entre el usuario, su rol y el recurso solicitado
    const resourceRole = await ResourceRole.findOne({
      include: [
        {
          model: Role,
          include: [
            {
              model: RoleUser,
              where: { user_id: userId, is_active: "ACTIVE" }, // Validar que el usuario esté asociado al rol
            },
          ],
          where: { is_active: "ACTIVE" }, // Validar que el rol esté activo
        },
      ],
      where: { resource_id: matchingResource.id, is_active: "ACTIVE" }, // Validar que la relación resource_role esté activa
    });

    return !!resourceRole; // Retorna true si se encuentra un registro coincidente
  } catch (error) {
    console.error('Error al validar la autorización:', error);
    return false;
  }
};
EOF

  echo -e "${GREEN}✅ Archivo src/middleware/auth.ts creado correctamente.${NC}"
  pause
}

# ===============================
# 🧭 MENÚ PRINCIPAL
# ===============================
while true; do
  clear
  echo -e "${YELLOW}==============================================${NC}"
  echo -e "${CYAN}     🧩 Asistente de Proyecto Node.js (WSL)    ${NC}"
  echo -e "${YELLOW}==============================================${NC}"
  echo -e "1. Instalar wget"
  echo -e "2. Instalar NVM"
  echo -e "3. Instalar Node.js"
  echo -e "4. Crear carpeta del proyecto"
  echo -e "5. Abrir Visual Studio Code"
  echo -e "6. Inicializar proyecto Node + TypeScript"
  echo -e "7. Instalar dependencias core"
  echo -e "8. Crear estructura de carpetas"
  echo -e "9. Crear archivos base (server.ts / config/index.ts)"
  echo -e "10. Instalar dependencias de base de datos"
  echo -e "11. Crear archivo .env"
  echo -e "12. Crear configuración de base de datos"
  echo -e "13. Instalar dependencias de autenticación"
  echo -e "14. Ejecutar servidor (npm run dev)"
  echo -e "15. --Ahora debes copiar y pegar src/models/authorization/ (manualmente)"
  echo -e "16. --Ahora debes haces los modelos de el proyecto (manualmente)"
  echo -e "17. --Ahora debes copiar y pegar src/controllers/Authorization (manualmente)"
  echo -e "18. --Ahora debes haces los controllers de el proyecto (manualmente)"
  echo -e "19. --Ahora debes copiar y pegar src/routes/authorization (manualmente)"
  echo -e "20. --Ahora debes haces las rutas de el proyecto (manualmente)"
  echo -e "21. Crear src/routes/index.ts (cambia las lineas de errores por los correctos)"
  echo -e "22. Actualizar src/config/index.ts con rutas"
  echo -e "23. --Instalar la extension Rest Client (manualmente)"
  echo -e "24. --Ahora debes copiar y pegar src/http/authorization/ (manualmente)"
  echo -e "25. --Ahora debes hacer los http de tu project (manualmente)"
  echo -e "26. Instalar faker y crear script de población de datos"
  echo -e "27. Actualizar src/config/index.ts (final)"
  echo -e "28. Crear middleware de autenticación (auth.ts)"
  echo -e "0. Salir"
  echo -e "${YELLOW}==============================================${NC}"
  read -p "Selecciona una opción: " opcion

  case $opcion in
    1) instalar_wget ;;
    2) instalar_nvm ;;
    3) instalar_node ;;
    4) crear_carpeta_proyecto ;;
    5) iniciar_vscode ;;
    6) iniciar_proyecto_node ;;
    7) instalar_dependencias_core ;;
    8) crear_estructura_directorios ;;
    9) crear_archivos_base ;;
    10) instalar_dependencias_db ;;
    11) crear_archivo_env ;;
    12) crear_config_db ;;
    13) instalar_dependencias_auth ;;
    14) ejecutar_servidor ;;
    21) crear_routes_index ;;
    22) actualizar_config_index_con_rutas ;;
    27) actualizar_config_index_final ;;
    26) instalar_faker_y_crear_script ;;
    28) crear_middleware_auth ;;
    0) echo "Saliendo..."; exit 0 ;;
    *) echo "Opción inválida."; pause ;;
  esac
done
