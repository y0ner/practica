import { Request, Response } from "express";
import { Checkin } from "../models/Checkin";

export class CheckinController {

  // Obtener todos los checkins
  public async getAllCheckins(req: Request, res: Response) {
    try {
      const checkins = await Checkin.findAll();
      res.status(200).json(checkins);
    } catch (error) {
      res.status(500).json({ error: "Error fetching checkins" });
    }
  }

  // Obtener checkin por ID
  public async getCheckinById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const checkin = await Checkin.findOne({ where: { id: pk } });

      if (!checkin) {
        return res.status(404).json({ error: "Checkin not found" });
      }

      res.status(200).json(checkin);
    } catch (error) {
      res.status(500).json({ error: "Error fetching checkin" });
    }
  }
}
