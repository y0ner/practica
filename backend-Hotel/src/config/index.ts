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
    this.routePrv.seasonRoutes.routes(this.app);
    this.routePrv.roomTypeRoutes.routes(this.app);
    this.routePrv.reservationServiceRoutes.routes(this.app);
    this.routePrv.hotelRoutes.routes(this.app);
    this.routePrv.serviceRoutes.routes(this.app);
    this.routePrv.reservationRoutes.routes(this.app);
    this.routePrv.checkoutRoutes.routes(this.app);
    this.routePrv.rateRoutes.routes(this.app);
    this.routePrv.roomRoutes.routes(this.app);
    this.routePrv.paymentRoutes.routes(this.app);
    this.routePrv.clientRoutes.routes(this.app);
    this.routePrv.checkinRoutes.routes(this.app);

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
      console.log(`🔗 Intentando conectar a: ${dbInfo.engine.toUpperCase()}`);
      const isConnected = await testConnection();
      if (!isConnected) {
        throw new Error(`No se pudo conectar a la base de datos ${dbInfo.engine.toUpperCase()}`);
      }
      await sequelize.sync({ force: false });
      // await sequelize.query('SET FOREIGN_KEY_CHECKS = 0;');
      // await sequelize.sync({ force: true });
      // await sequelize.query('SET FOREIGN_KEY_CHECKS = 1;');
      console.log(`📦 Base de datos sincronizada exitosamente`);
    } catch (error) {
      console.error("❌ Error al conectar con la base de datos:", error);
      process.exit(1);
    }
  }

  async listen() {
    await this.app.listen(this.app.get('port'));
    console.log(`🚀 Servidor ejecutándose en puerto ${this.app.get('port')}`);
  }
}
