import { Application } from "express";
import { CheckinController } from "../controllers/Checkin.Controller";
import { authMiddleware } from "../middleware/auth";

export class CheckinRoutes {
  public checkinController: CheckinController = new CheckinController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Checkins/public")
    //   .get(this.checkinController.getAllCheckins);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Checkins")
      .get(authMiddleware, this.checkinController.getAllCheckins);

    app.route("/api/Checkins/:id")
      .get(authMiddleware, this.checkinController.getCheckinById);

  }
}
