import { Request, Response } from "express";
import { Payment, PaymentI } from "../models/Payment";

export class PaymentController {

  // Obtener todos los pagos
  public async getAllPayments(req: Request, res: Response) {
    try {
      const payments: PaymentI[] = await Payment.findAll({
        where: { status: "ACTIVE" }
      });
      res.status(200).json(payments);
    } catch (error) {
      res.status(500).json({ error: "Error fetching payments" });
    }
  }

  // Obtener un pago por ID
  public async getPaymentById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const payment = await Payment.findOne({
        where: { id: pk, status: "ACTIVE" }
      });

      if (payment) {
        res.status(200).json(payment);
      } else {
        res.status(404).json({ error: "Payment not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching payment" });
    }
  }

  // Crear un nuevo pago
  public async createPayment(req: Request, res: Response) {
    const { reservation_id, amount, method, currency, payment_date, reference } = req.body;

    try {
      let body: PaymentI = {
        reservation_id,
        amount,
        method,
        currency,
        payment_date,
        reference,
        status: "ACTIVE"
      };

      const newPayment = await Payment.create(body as any);
      res.status(201).json(newPayment);

    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  // Cancelar un pago (borrado lógico profesional)
  public async cancelPayment(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;

      const payment = await Payment.findOne({
        where: { id: pk, status: "ACTIVE" }
      });

      if (!payment) {
        return res.status(404).json({ error: "Payment not found or already cancelled" });
      }

      await payment.update({ status: "CANCELLED" });

      res.status(200).json({ message: "Payment successfully cancelled" });

    } catch (error) {
      res.status(500).json({ error: "Error cancelling payment" });
    }
  }
}
