import { Application } from "express";
import { SaleController } from "../controllers/Sale.Controller";
import { authMiddleware } from "../middleware/auth";

export class SaleRoutes {
  public saleController: SaleController = new SaleController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Sales/public")
    //   .get(this.saleController.getAllSales);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Sales")
      .get(authMiddleware, this.saleController.getAllSales)
      .post(authMiddleware, this.saleController.createSale);

    app.route("/api/Sales/:id")
      .get(authMiddleware, this.saleController.getSaleById)
      .patch(authMiddleware, this.saleController.updateSale);

    app.route("/api/Sales/:id/logic")
      .delete(authMiddleware, this.saleController.deleteSaleAdv);
  }
}
