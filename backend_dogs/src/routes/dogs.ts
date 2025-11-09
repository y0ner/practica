import { Application } from "express";
import { DogsController } from "../controllers/dogs.controller";
import { authMiddleware } from "../middleware/auth"; // Importamos el middleware

export class DogsRoutes {
  public dogsController: DogsController = new DogsController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (SIN AUTENTICACIÓN) ==================
    app.route("/api/dogs/public")
      .get(this.dogsController.getAllDogs)
      .post(this.dogsController.createDogs);

    app.route("/api/dogs/public/:id")
      .get(this.dogsController.getDogsById)
      .patch(this.dogsController.updateDogs)
      .delete(this.dogsController.deleteDogs);

    app.route("/api/dogs/public/:id/logic")
      .delete(this.dogsController.deleteDogsAdv);

    // ================== RUTAS PROTEGIDAS (CON AUTENTICACIÓN) ==================
    app.route("/api/dogs")
      .get(authMiddleware, this.dogsController.getAllDogs)
      .post(authMiddleware, this.dogsController.createDogs);

    app.route("/api/dogs/:id")
      .get(authMiddleware, this.dogsController.getDogsById)
      .patch(authMiddleware, this.dogsController.updateDogs)
      .delete(authMiddleware, this.dogsController.deleteDogs);

    app.route("/api/dogs/:id/logic")
      .delete(authMiddleware, this.dogsController.deleteDogsAdv);
  }
}