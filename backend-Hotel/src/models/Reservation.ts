import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Client } from "./Client";
import { Room } from "./Room";
import { Checkin } from "./Checkin";
import { Service } from "./Service";
import { Payment } from "./Payment";
import { Checkout } from "./Checkout";

export interface ReservationI {
  id?: number;
  reservation_date: Date;
  checkin_date: Date;
  checkout_date: Date;
  number_of_guests: number;
  total_amount: number;
  client_id: number;
  room_id: number;
  status: "ACTIVE" | "INACTIVE";
}

export class Reservation extends Model<ReservationI> implements ReservationI {
  public reservation_date!: Date;
  public checkin_date!: Date;
  public checkout_date!: Date;
  public number_of_guests!: number;
  public total_amount!: number;
  public client_id!: number;
  public room_id!: number;
  public status!: "ACTIVE" | "INACTIVE";
}

Reservation.init(
  {
    reservation_date: {
      type: DataTypes.DATE,
      allowNull: false
    },
    checkin_date: {
      type: DataTypes.DATE,
      allowNull: false
    },
    checkout_date: {
      type: DataTypes.DATE,
      allowNull: false
    },
    number_of_guests: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    total_amount: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    client_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    room_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "Reservation",
    tableName: "reservations",
    timestamps: false,
  }
);
