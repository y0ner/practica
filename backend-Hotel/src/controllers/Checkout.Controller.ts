import { Request, Response } from "express";
import { Checkout } from "../models/Checkout";

export class CheckoutController {

  // Obtener todos los checkouts
  public async getAllCheckouts(req: Request, res: Response) {
    try {
      const checkouts = await Checkout.findAll();
      res.status(200).json(checkouts);
    } catch (error) {
      res.status(500).json({ error: "Error fetching checkouts" });
    }
  }

  // Obtener checkout por ID
  public async getCheckoutById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const checkout = await Checkout.findOne({ where: { id: pk } });

      if (!checkout) {
        return res.status(404).json({ error: "Checkout not found" });
      }

      res.status(200).json(checkout);
    } catch (error) {
      res.status(500).json({ error: "Error fetching checkout" });
    }
  }
}
