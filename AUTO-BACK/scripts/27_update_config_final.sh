#!/bin/bash

# ==========================================
# 2️⃣7️⃣ Actualizar src/config/index.ts (final)
# Autor: Yoner
# ==========================================

. "$(dirname "$0")/utils.sh"

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