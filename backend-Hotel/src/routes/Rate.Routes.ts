import { Application } from "express";
import { RateController } from "../controllers/Rate.Controller";
import { authMiddleware } from "../middleware/auth";

export class RateRoutes {
  public rateController: RateController = new RateController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Rates/public")
    //   .get(this.rateController.getAllRates);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Rates")
      .get(authMiddleware, this.rateController.getAllRates)
      .post(authMiddleware, this.rateController.createRate);

    app.route("/api/Rates/:id")
      .get(authMiddleware, this.rateController.getRateById)
      .patch(authMiddleware, this.rateController.updateRate);

    app.route("/api/Rates/:id/logic")
      .delete(authMiddleware, this.rateController.deleteRateAdv);
  }
}
