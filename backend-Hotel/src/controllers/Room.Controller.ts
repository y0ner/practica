import { Request, Response } from "express";
import { Room, RoomI } from "../models/Room";

export class RoomController {

  public async getAllRooms(req: Request, res: Response) {
    try {
      const rooms: RoomI[] = await Room.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(rooms);
    } catch (error) {
      res.status(500).json({ error: "Error fetching rooms" });
    }
  }

  public async getRoomById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const room = await Room.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (room) {
        res.status(200).json(room);
      } else {
        res.status(404).json({ error: "Room not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching room" });
    }
  }

  public async createRoom(req: Request, res: Response) {
    const { id,roomtype_id,hotel_id,number,floor,capacity,description,base_price,available,status } = req.body;
    try {
      let body: RoomI = { roomtype_id,hotel_id,number,floor,capacity,description,base_price,available, status };
      const newRoom = await Room.create(body as any);
      res.status(201).json(newRoom);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateRoom(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,roomtype_id,hotel_id,number,floor,capacity,description,base_price,available,status } = req.body;
  try {
    const roomExist = await Room.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: RoomI = { roomtype_id,hotel_id,number,floor,capacity,description,base_price,available, status };
      if (roomExist) {
        await roomExist.update(body);
        res.status(200).json(roomExist);
      } else {
        res.status(404).json({ error: "Room not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteRoomAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const roomToUpdate = await Room.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (roomToUpdate) {
        await roomToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Room marked as inactive" });
      } else {
        res.status(404).json({ error: "Room not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking room as inactive" });
    }
  }
}
