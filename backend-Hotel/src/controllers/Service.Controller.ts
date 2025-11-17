import { Request, Response } from "express";
import { Service, ServiceI } from "../models/Service";

export class ServiceController {

  public async getAllServices(req: Request, res: Response) {
    try {
      const services: ServiceI[] = await Service.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(services);
    } catch (error) {
      res.status(500).json({ error: "Error fetching services" });
    }
  }

  public async getServiceById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const service = await Service.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (service) {
        res.status(200).json(service);
      } else {
        res.status(404).json({ error: "Service not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching service" });
    }
  }

  public async createService(req: Request, res: Response) {
    const { id,name,description,price,category,status } = req.body;
    try {
      let body: ServiceI = { name,description,price,category, status };
      const newService = await Service.create(body as any);
      res.status(201).json(newService);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateService(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,name,description,price,category,status } = req.body;
  try {
    const serviceExist = await Service.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: ServiceI = { name,description,price,category, status };
      if (serviceExist) {
        await serviceExist.update(body);
        res.status(200).json(serviceExist);
      } else {
        res.status(404).json({ error: "Service not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteServiceAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const serviceToUpdate = await Service.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (serviceToUpdate) {
        await serviceToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Service marked as inactive" });
      } else {
        res.status(404).json({ error: "Service not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking service as inactive" });
    }
  }
}
