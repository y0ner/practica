import { Request, Response } from "express";
import { RoomType, RoomTypeI } from "../models/RoomType";

export class RoomTypeController {

  public async getAllRoomTypes(req: Request, res: Response) {
    try {
      const roomtypes: RoomTypeI[] = await RoomType.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(roomtypes);
    } catch (error) {
      res.status(500).json({ error: "Error fetching roomtypes" });
    }
  }

  public async getRoomTypeById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const roomtype = await RoomType.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (roomtype) {
        res.status(200).json(roomtype);
      } else {
        res.status(404).json({ error: "RoomType not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching roomtype" });
    }
  }

  public async createRoomType(req: Request, res: Response) {
    const { id,name,description,max_people,includes_breakfast,status } = req.body;
    try {
      let body: RoomTypeI = { name,description,max_people,includes_breakfast, status };
      const newRoomType = await RoomType.create(body as any);
      res.status(201).json(newRoomType);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateRoomType(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,name,description,max_people,includes_breakfast,status } = req.body;
  try {
    const roomtypeExist = await RoomType.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: RoomTypeI = { name,description,max_people,includes_breakfast, status };
      if (roomtypeExist) {
        await roomtypeExist.update(body);
        res.status(200).json(roomtypeExist);
      } else {
        res.status(404).json({ error: "RoomType not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteRoomTypeAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const roomtypeToUpdate = await RoomType.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (roomtypeToUpdate) {
        await roomtypeToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "RoomType marked as inactive" });
      } else {
        res.status(404).json({ error: "RoomType not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking roomtype as inactive" });
    }
  }
}
