import { Application } from "express";
import { CheckoutController } from "../controllers/Checkout.Controller";
import { authMiddleware } from "../middleware/auth";

export class CheckoutRoutes {
  public checkoutController: CheckoutController = new CheckoutController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Checkouts/public")
    //   .get(this.checkoutController.getAllCheckouts);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Checkouts")
      .get(authMiddleware, this.checkoutController.getAllCheckouts);

    app.route("/api/Checkouts/:id")
      .get(authMiddleware, this.checkoutController.getCheckoutById);

  }
}
