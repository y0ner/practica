import { Application } from "express";
import { ServiceController } from "../controllers/Service.Controller";
import { authMiddleware } from "../middleware/auth";

export class ServiceRoutes {
  public serviceController: ServiceController = new ServiceController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Services/public")
    //   .get(this.serviceController.getAllServices);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Services")
      .get(authMiddleware, this.serviceController.getAllServices)
      .post(authMiddleware, this.serviceController.createService);

    app.route("/api/Services/:id")
      .get(authMiddleware, this.serviceController.getServiceById)
      .patch(authMiddleware, this.serviceController.updateService);

    app.route("/api/Services/:id/logic")
      .delete(authMiddleware, this.serviceController.deleteServiceAdv);
  }
}
