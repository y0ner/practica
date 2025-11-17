import { Application } from "express";
import { ReservationController } from "../controllers/Reservation.Controller";
import { authMiddleware } from "../middleware/auth";

export class ReservationRoutes {
  public reservationController: ReservationController = new ReservationController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Reservations/public")
    //   .get(this.reservationController.getAllReservations);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Reservations")
      .get(authMiddleware, this.reservationController.getAllReservations)
      .post(authMiddleware, this.reservationController.createReservation);

    app.route("/api/Reservations/:id")
      .get(authMiddleware, this.reservationController.getReservationById)
      .patch(authMiddleware, this.reservationController.updateReservation);

    app.route("/api/Reservations/:id/logic")
      .delete(authMiddleware, this.reservationController.deleteReservationAdv);
  }
}
