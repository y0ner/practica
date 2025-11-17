import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";
import { Reservation } from "./Reservation";

export interface PaymentI {
  id?: number;
  amount: number;
  method: string;
  currency: string;
  payment_date: Date;
  reference: string;
  reservation_id: number;
  status?: string;
}

export class Payment extends Model<PaymentI> implements PaymentI {
  public amount!: number;
  public method!: string;
  public currency!: string;
  public payment_date!: Date;
  public reference!: string;
  public reservation_id!: number;
  public status!: string;
}

Payment.init(
  {
    amount: {
      type: DataTypes.FLOAT,
      allowNull: false
    },
    method: {
      type: DataTypes.STRING,
      allowNull: false
    },
    currency: {
      type: DataTypes.STRING,
      allowNull: false
    },
    payment_date: {
      type: DataTypes.DATE,
      allowNull: false
    },
    reference: {
      type: DataTypes.STRING,
      allowNull: true
    },
    reservation_id: {
      type: DataTypes.INTEGER,
      allowNull: false
    },
    status: {
      type: DataTypes.ENUM("ACTIVE", "CANCELLED"),
      defaultValue: "ACTIVE",
      allowNull: false
    }
  },
  {
    sequelize,
    modelName: "Payment",
    tableName: "payments",
    timestamps: false,
  }
);
