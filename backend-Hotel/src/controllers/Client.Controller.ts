import { Request, Response } from "express";
import { Client, ClientI } from "../models/Client";

export class ClientController {

  public async getAllClients(req: Request, res: Response) {
    try {
      const clients: ClientI[] = await Client.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(clients);
    } catch (error) {
      res.status(500).json({ error: "Error fetching clients" });
    }
  }

  public async getClientById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const client = await Client.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (client) {
        res.status(200).json(client);
      } else {
        res.status(404).json({ error: "Client not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching client" });
    }
  }

  public async createClient(req: Request, res: Response) {
    const { id,first_name,last_name,document,phone,email,nationality,status } = req.body;
    try {
      let body: ClientI = { first_name,last_name,document,phone,email,nationality, status };
      const newClient = await Client.create(body as any);
      res.status(201).json(newClient);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateClient(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,first_name,last_name,document,phone,email,nationality,status } = req.body;
  try {
    const clientExist = await Client.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: ClientI = { first_name,last_name,document,phone,email,nationality, status };
      if (clientExist) {
        await clientExist.update(body);
        res.status(200).json(clientExist);
      } else {
        res.status(404).json({ error: "Client not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteClientAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const clientToUpdate = await Client.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (clientToUpdate) {
        await clientToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Client marked as inactive" });
      } else {
        res.status(404).json({ error: "Client not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking client as inactive" });
    }
  }
}
