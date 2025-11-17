import { Request, Response } from "express";
import { Rate, RateI } from "../models/Rate";

export class RateController {

  public async getAllRates(req: Request, res: Response) {
    try {
      const rates: RateI[] = await Rate.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(rates);
    } catch (error) {
      res.status(500).json({ error: "Error fetching rates" });
    }
  }

  public async getRateById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const rate = await Rate.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (rate) {
        res.status(200).json(rate);
      } else {
        res.status(404).json({ error: "Rate not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching rate" });
    }
  }

  public async createRate(req: Request, res: Response) {
    const { id,season_id,roomtype_id,amount,currency,description,refundable,status } = req.body;
    try {
      let body: RateI = { season_id,roomtype_id,amount,currency,description,refundable, status };
      const newRate = await Rate.create(body as any);
      res.status(201).json(newRate);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateRate(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,season_id,roomtype_id,amount,currency,description,refundable,status } = req.body;
  try {
    const rateExist = await Rate.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: RateI = { season_id,roomtype_id,amount,currency,description,refundable, status };
      if (rateExist) {
        await rateExist.update(body);
        res.status(200).json(rateExist);
      } else {
        res.status(404).json({ error: "Rate not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteRateAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const rateToUpdate = await Rate.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (rateToUpdate) {
        await rateToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Rate marked as inactive" });
      } else {
        res.status(404).json({ error: "Rate not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking rate as inactive" });
    }
  }
}
