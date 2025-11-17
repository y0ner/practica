import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Reservation } from "./Reservation";

export interface CheckoutI {
  id?: number;
  time: Date;
  observation?: string;
  reservation_id: number;
}

export class Checkout extends Model<CheckoutI> implements CheckoutI {
  public time!: Date;
  public observation?: string;
  public reservation_id!: number;
}

Checkout.init(
  {
    time: {
      type: DataTypes.DATE,
      allowNull: false,
    },
    observation: {
      type: DataTypes.TEXT,
      allowNull: true,
    },
    reservation_id: {
      type: DataTypes.INTEGER,
      allowNull: false,
    }
  },
  {
    sequelize,
    modelName: "Checkout",
    tableName: "checkouts",
    timestamps: false,
  }
);
