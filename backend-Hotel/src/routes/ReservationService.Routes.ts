import { Application } from "express";
import { ReservationServiceController } from "../controllers/ReservationService.Controller";
import { authMiddleware } from "../middleware/auth";

export class ReservationServiceRoutes {
  public reservationserviceController: ReservationServiceController = new ReservationServiceController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/ReservationServices/public")
    //   .get(this.reservationserviceController.getAllReservationServices);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/ReservationServices")
      .get(authMiddleware, this.reservationserviceController.getAllReservationServices);

    app.route("/api/ReservationServices/:id")
      .get(authMiddleware, this.reservationserviceController.getReservationServiceById);

  }
}
