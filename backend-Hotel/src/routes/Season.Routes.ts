import { Application } from "express";
import { SeasonController } from "../controllers/Season.Controller";
import { authMiddleware } from "../middleware/auth";

export class SeasonRoutes {
  public seasonController: SeasonController = new SeasonController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Seasons/public")
    //   .get(this.seasonController.getAllSeasons);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Seasons")
      .get(authMiddleware, this.seasonController.getAllSeasons)
      .post(authMiddleware, this.seasonController.createSeason);

    app.route("/api/Seasons/:id")
      .get(authMiddleware, this.seasonController.getSeasonById)
      .patch(authMiddleware, this.seasonController.updateSeason);

    app.route("/api/Seasons/:id/logic")
      .delete(authMiddleware, this.seasonController.deleteSeasonAdv);
  }
}
