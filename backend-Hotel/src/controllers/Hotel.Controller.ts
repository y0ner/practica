import { Request, Response } from "express";
import { Hotel, HotelI } from "../models/Hotel";

export class HotelController {

  public async getAllHotels(req: Request, res: Response) {
    try {
      const hotels: HotelI[] = await Hotel.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(hotels);
    } catch (error) {
      res.status(500).json({ error: "Error fetching hotels" });
    }
  }

  public async getHotelById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const hotel = await Hotel.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (hotel) {
        res.status(200).json(hotel);
      } else {
        res.status(404).json({ error: "Hotel not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching hotel" });
    }
  }

  public async createHotel(req: Request, res: Response) {
    const { id,name,address,city,country,phone,stars,status } = req.body;
    try {
      let body: HotelI = { name,address,city,country,phone,stars, status };
      const newHotel = await Hotel.create(body as any);
      res.status(201).json(newHotel);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateHotel(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,name,address,city,country,phone,stars,status } = req.body;
  try {
    const hotelExist = await Hotel.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: HotelI = { name,address,city,country,phone,stars, status };
      if (hotelExist) {
        await hotelExist.update(body);
        res.status(200).json(hotelExist);
      } else {
        res.status(404).json({ error: "Hotel not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteHotelAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const hotelToUpdate = await Hotel.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (hotelToUpdate) {
        await hotelToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Hotel marked as inactive" });
      } else {
        res.status(404).json({ error: "Hotel not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking hotel as inactive" });
    }
  }
}
