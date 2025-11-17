import { Application } from "express";
import { HotelController } from "../controllers/Hotel.Controller";
import { authMiddleware } from "../middleware/auth";

export class HotelRoutes {
  public hotelController: HotelController = new HotelController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Hotels/public")
    //   .get(this.hotelController.getAllHotels);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Hotels")
      .get(authMiddleware, this.hotelController.getAllHotels)
      .post(authMiddleware, this.hotelController.createHotel);

    app.route("/api/Hotels/:id")
      .get(authMiddleware, this.hotelController.getHotelById)
      .patch(authMiddleware, this.hotelController.updateHotel);

    app.route("/api/Hotels/:id/logic")
      .delete(authMiddleware, this.hotelController.deleteHotelAdv);
  }
}
