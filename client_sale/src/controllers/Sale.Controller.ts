import { Request, Response } from "express";
import { Sale, SaleI } from "../models/Sale";

export class SaleController {

  public async getAllSales(req: Request, res: Response) {
    try {
      const sales: SaleI[] = await Sale.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(sales);
    } catch (error) {
      res.status(500).json({ error: "Error fetching sales" });
    }
  }

  public async getSaleById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const sale = await Sale.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (sale) {
        res.status(200).json(sale);
      } else {
        res.status(404).json({ error: "Sale not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching sale" });
    }
  }

  public async createSale(req: Request, res: Response) {
    const { id,client_id,sale_date,subtotal,tax,discounts,total,status } = req.body;
    try {
      let body: SaleI = { client_id,sale_date,subtotal,tax,discounts,total, status };
      const newSale = await Sale.create(body as any);
      res.status(201).json(newSale);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateSale(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,client_id,sale_date,subtotal,tax,discounts,total,status } = req.body;
  try {
    const saleExist = await Sale.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: SaleI = { client_id,sale_date,subtotal,tax,discounts,total, status };
      if (saleExist) {
        await saleExist.update(body);
        res.status(200).json(saleExist);
      } else {
        res.status(404).json({ error: "Sale not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteSaleAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const saleToUpdate = await Sale.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (saleToUpdate) {
        await saleToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Sale marked as inactive" });
      } else {
        res.status(404).json({ error: "Sale not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking sale as inactive" });
    }
  }
}
