import { Application } from "express";
import { RoomController } from "../controllers/Room.Controller";
import { authMiddleware } from "../middleware/auth";

export class RoomRoutes {
  public roomController: RoomController = new RoomController();

  public routes(app: Application): void {
    // ================== RUTAS PÚBLICAS (EJEMPLO) ==================
    // Si necesitas rutas que no requieran autenticación, puedes añadirlas aquí
    // app.route("/api/Rooms/public")
    //   .get(this.roomController.getAllRooms);

    // ================== RUTAS CON AUTENTICACIÓN ==================
    app.route("/api/Rooms")
      .get(authMiddleware, this.roomController.getAllRooms)
      .post(authMiddleware, this.roomController.createRoom);

    app.route("/api/Rooms/:id")
      .get(authMiddleware, this.roomController.getRoomById)
      .patch(authMiddleware, this.roomController.updateRoom);

    app.route("/api/Rooms/:id/logic")
      .delete(authMiddleware, this.roomController.deleteRoomAdv);
  }
}
