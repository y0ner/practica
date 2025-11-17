import { Request, Response } from "express";
import { ReservationService, ReservationServiceI } from "../models/ReservationService";

export class ReservationServiceController {

  public async getAllReservationServices(req: Request, res: Response) {
    try {
      const reservationservices = await ReservationService.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(reservationservices);
    } catch (error) {
      res.status(500).json({ error: "Error fetching reservationservices" });
    }
  }

  public async getReservationServiceById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const reservationservice = await ReservationService.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (!reservationservice) {
        return res.status(404).json({ error: "ReservationService not found" });
      }
      res.status(200).json(reservationservice);
    } catch (error) {
      res.status(500).json({ error: "Error fetching reservationservice" });
    }
  }
}
