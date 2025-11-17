import { Request, Response } from "express";
import { Season, SeasonI } from "../models/Season";

export class SeasonController {

  public async getAllSeasons(req: Request, res: Response) {
    try {
      const seasons: SeasonI[] = await Season.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(seasons);
    } catch (error) {
      res.status(500).json({ error: "Error fetching seasons" });
    }
  }

  public async getSeasonById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const season = await Season.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (season) {
        res.status(200).json(season);
      } else {
        res.status(404).json({ error: "Season not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching season" });
    }
  }

  public async createSeason(req: Request, res: Response) {
    const { id,name,start_date,end_date,price_multiplier,status } = req.body;
    try {
      let body: SeasonI = { name,start_date,end_date,price_multiplier, status };
      const newSeason = await Season.create(body as any);
      res.status(201).json(newSeason);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateSeason(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,name,start_date,end_date,price_multiplier,status } = req.body;
  try {
    const seasonExist = await Season.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: SeasonI = { name,start_date,end_date,price_multiplier, status };
      if (seasonExist) {
        await seasonExist.update(body);
        res.status(200).json(seasonExist);
      } else {
        res.status(404).json({ error: "Season not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteSeasonAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const seasonToUpdate = await Season.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (seasonToUpdate) {
        await seasonToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Season marked as inactive" });
      } else {
        res.status(404).json({ error: "Season not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking season as inactive" });
    }
  }
}
