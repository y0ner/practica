import { DataTypes, Model } from "sequelize";
import { sequelize } from "../database/db";

export interface PaymentI {
  id?: number;
  amount: number;
  method: string;
  currency: string;
  payment_date: Date;
  reference: string;
  status: "ACTIVE" | "INACTIVE";
}

export class Payment extends Model<PaymentI> implements PaymentI {
  public amount!: number;
  public method!: string;
  public currency!: string;
  public payment_date!: Date;
  public reference!: string;
  public status!: "ACTIVE" | "INACTIVE";
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
    status: {
      type: DataTypes.ENUM("ACTIVE", "INACTIVE"),
      defaultValue: "ACTIVE",
    },
  },
  {
    sequelize,
    modelName: "Payment",
    tableName: "payments",
    timestamps: false,
  }
);


