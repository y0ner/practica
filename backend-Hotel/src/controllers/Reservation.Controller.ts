import { Request, Response } from "express";
import { Reservation, ReservationI } from "../models/Reservation";

export class ReservationController {

  public async getAllReservations(req: Request, res: Response) {
    try {
      const reservations: ReservationI[] = await Reservation.findAll({ where: { status: 'ACTIVE' } });
      res.status(200).json(reservations);
    } catch (error) {
      res.status(500).json({ error: "Error fetching reservations" });
    }
  }

  public async getReservationById(req: Request, res: Response) {
    try {
      const { id: pk } = req.params;
      const reservation = await Reservation.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (reservation) {
        res.status(200).json(reservation);
      } else {
        res.status(404).json({ error: "Reservation not found or inactive" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error fetching reservation" });
    }
  }

  public async createReservation(req: Request, res: Response) {
    const { id,client_id,room_id,reservation_date,checkin_date,checkout_date,number_of_guests,total_amount,status } = req.body;
    try {
      let body: ReservationI = { client_id,room_id,reservation_date,checkin_date,checkout_date,number_of_guests,total_amount, status };
      const newReservation = await Reservation.create(body as any);
      res.status(201).json(newReservation);
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async updateReservation(req: Request, res: Response) {
  const { id: pk } = req.params;
  const { id,client_id,room_id,reservation_date,checkin_date,checkout_date,number_of_guests,total_amount,status } = req.body;
  try {
    const reservationExist = await Reservation.findOne({ where: { id: pk, status: 'ACTIVE' } });
    let body: ReservationI = { client_id,room_id,reservation_date,checkin_date,checkout_date,number_of_guests,total_amount, status };
      if (reservationExist) {
        await reservationExist.update(body);
        res.status(200).json(reservationExist);
      } else {
        res.status(404).json({ error: "Reservation not found or inactive" });
      }
    } catch (error: any) {
      res.status(400).json({ error: error.message });
    }
  }

  public async deleteReservationAdv(req: Request, res: Response) {
    const { id: pk } = req.params;
    try {
      const reservationToUpdate = await Reservation.findOne({ where: { id: pk, status: 'ACTIVE' } });
      if (reservationToUpdate) {
        await reservationToUpdate.update({ status: 'INACTIVE' });
        res.status(200).json({ message: "Reservation marked as inactive" });
      } else {
        res.status(404).json({ error: "Reservation not found" });
      }
    } catch (error) {
      res.status(500).json({ error: "Error marking reservation as inactive" });
    }
  }
}
