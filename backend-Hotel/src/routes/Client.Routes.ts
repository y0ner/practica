import { Application } from "express";
import { ClientController } from "../controllers/Client.Controller";
import { authMiddleware } from "../middleware/auth";

export class ClientRoutes {
  public clientController: ClientController = new ClientController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Clients/public")
    //   .get(this.clientController.getAllClients);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Clients")
      .get(authMiddleware, this.clientController.getAllClients)
      .post(authMiddleware, this.clientController.createClient);

    app.route("/api/Clients/:id")
      .get(authMiddleware, this.clientController.getClientById)
      .patch(authMiddleware, this.clientController.updateClient);

    app.route("/api/Clients/:id/logic")
      .delete(authMiddleware, this.clientController.deleteClientAdv);
  }
}
