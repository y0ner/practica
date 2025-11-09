import { Application } from "express";
import { BreedsController } from "../controllers/breeds.controller";
import { authMiddleware } from "../middleware/auth"; // Importamos el middleware

export class BreedsRoutes {
  public breedsController: BreedsController = new BreedsController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (SIN AUTENTICACIÓN) ==================
    app.route("/api/breeds/public")
      .get(this.breedsController.getAllBreedss)
      .post(this.breedsController.createBreeds);

    app.route("/api/breeds/public/:id")
      .get(this.breedsController.getBreedsById)
      .patch(this.breedsController.updateBreeds)
      .delete(this.breedsController.deleteBreeds);

    app.route("/api/breeds/public/:id/logic")
      .delete(this.breedsController.deleteBreedsAdv);

    // ================== RUTAS PROTEGIDAS (CON AUTENTICACIÓN) ==================
    app.route("/api/breeds")
      .get(authMiddleware, this.breedsController.getAllBreedss)
      .post(authMiddleware, this.breedsController.createBreeds);

    app.route("/api/breeds/:id")
      .get(authMiddleware, this.breedsController.getBreedsById)
      .patch(authMiddleware, this.breedsController.updateBreeds)
      .delete(authMiddleware, this.breedsController.deleteBreeds);

    app.route("/api/breeds/:id/logic")
      .delete(authMiddleware, this.breedsController.deleteBreedsAdv);
  }
}